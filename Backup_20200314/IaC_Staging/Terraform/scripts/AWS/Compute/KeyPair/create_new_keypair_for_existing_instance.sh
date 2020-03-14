#!/usr/bin/sh
# This script will create the EC2 keypair in AWS and ppk file locally with the given name as argument
# add the new key to provided instance
# eg:  ./create_new_keypair_for_existing_instance.sh instance_name

AWS="/root/.local/bin/aws"    #aws executable full path
PUTTYGEN="/usr/bin/puttygen"  #putty tool from epel
REGION="ap-southeast-1"       #region where the keypair or ec2 instance to be created
LOCATION="/DATA/"             #location where the key files to be stored
temp_file=$(mktemp)
TIMEOUT=120                   #seconds, the while loop will wait for mentioned seconds for the instance to stop
CREATE_USER_DATA="./create_user_data.sh"  # location of dependant script
USER="ec2-user"               #login name for the instance 

Failed()
{
  echo -e "$1"
  exit 1
}

#[[ $(${AWS} sts get-caller-identity) ]] || Failed "AWS cli credentials are wrong / not set properly."
[[ -f ${PUTTYGEN} ]] || Failed "putty packages are not installed, install it from EPEL repo, exiting.."
[[ -d ${LOCATION} ]] || Failed "${LOCATION} doesn't exist, please create ${LOCATION} and try again"
[[ "$1" == "" ]] && Failed "You should call this script with argument as existing instance_name, exiting...\n  \
                            eg:  ./create_new_keypair_for_existing_instance.sh instance_name" || INSTANCE_NAME="$1"

# Check the instance is available
INSTANCE_ID=""
INSTANCE_ID=$(${AWS} ec2 describe-instances --region=${REGION} --filter "Name=tag:Name,Values=${INSTANCE_NAME}" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)
[[ $(${AWS} ec2 describe-instances --region=${REGION} --instance-ids ${INSTANCE_ID}) ]] || Failed "Failed to retrive the instance details with given instance name : ${INSTANCE_NAME}, exiting..."
KEY_PAIR_NAME="${INSTANCE_NAME}_key"

# Check key pair already available
[[ $(${AWS} ec2 describe-key-pairs --key-name ${KEY_PAIR_NAME} --region=${REGION} 2>/dev/null) ]] && Failed "key pair : ${KEY_PAIR_NAME} already exist, exiting..."

# Create key pair in AWS
${AWS} ec2 create-key-pair --region=${REGION} --key-name ${KEY_PAIR_NAME}  --query 'KeyMaterial' --output text > ${LOCATION}${KEY_PAIR_NAME}.pem
[[ $(${AWS} ec2 describe-key-pairs --key-name ${KEY_PAIR_NAME} --region=${REGION}) ]] || Failed "Creating key pair : ${KEY_PAIR_NAME} failed, exiting..."
[[ -f ${LOCATION}${KEY_PAIR_NAME}.pem ]] || Failed "Key pair created in AWS console, but failed to download private key in ${LOCATION}, exiting..."
chmod 400 ${LOCATION}${KEY_PAIR_NAME}.pem

# Stop instance and monitor for $TIMEOUT
${AWS} ec2 stop-instances --instance-ids ${INSTANCE_ID} --region=${REGION}
SECONDS=0
while true; do 
  sleep 30
  STATE=$(${AWS} ec2 describe-instance-status --instance-ids ${INSTANCE_ID} --region=${REGION} --output text --include-all-instances | \
                                                                                                  grep -w "INSTANCESTATE" | awk '{print $3}')
  [[ "${STATE}" == "stopped" ]] && break;
  [[ "${SECONDS}" -gt ${TIMEOUT} ]] && break;
done
[[ "${STATE}" == "stopped" ]] || Failed "Failed to stop instance ${INSTANCE_ID}, exiting..."

# create user data with private key
${CREATE_USER_DATA} ${USER} ${LOCATION}${KEY_PAIR_NAME}.pem > ${temp_file}
/usr/bin/base64 ${temp_file} > ${temp_file}_64
rm -f ${temp_file} ${temp_file}_64

# Update user data for the instance
${AWS} ec2 modify-instance-attribute --attribute userData --value file://${temp_file}_64 --instance-id ${INSTANCE_ID}

# Start instance
${AWS} ec2 start-instances --instance-ids ${INSTANCE_ID} --region=${REGION}
SECONDS=0
while true; do
  sleep 30
  STATE=$(${AWS} ec2 describe-instance-status --instance-ids ${INSTANCE_ID} --region=${REGION} --output text --include-all-instances | \
                                                                                                  grep -w "INSTANCESTATE" | awk '{print $3}')
  [[ "${STATE}" == "running" ]] && break;
  [[ "${SECONDS}" -gt ${TIMEOUT} ]] && break;
done
[[ "${STATE}" == "running" ]] || Failed "Failed to start instance ${INSTANCE_ID}, exiting..."

# Convert .pem file to .ppk file
${PUTTYGEN} ${LOCATION}${KEY_PAIR_NAME}.pem -o ${LOCATION}${KEY_PAIR_NAME}.ppk -O private
[[ -f ${LOCATION}${KEY_PAIR_NAME}.ppk ]] || Failed "Converting .pem file to .ppk file failed, exiting..." \
                  && echo "${LOCATION}${KEY_PAIR_NAME}.ppk created succesfully and user can download this and use in putty"


