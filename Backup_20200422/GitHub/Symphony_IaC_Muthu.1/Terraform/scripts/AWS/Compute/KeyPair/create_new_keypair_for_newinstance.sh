#!/usr/bin/sh
# This script will create the EC2 keypair in AWS and ppk file locally with the given name as argument

AWS="/root/.local/bin/aws"    #aws executable full path
PUTTYGEN="/usr/bin/puttygen"  #putty tool from epel
REGION="ap-southeast-1"       #region where the keypair or ec2 instance to be created
LOCATION="/DATA/"             #location where the key files to be stored

Failed()
{
  echo "$1"
  exit 1
}

[[ $(${AWS} sts get-caller-identity) ]] || Failed "AWS cli credentials are wrong / not set properly."
[[ -f ${PUTTYGEN} ]] || Failed "putty packages are not installed, install it from EPEL repo, exiting.."
[[ -d ${LOCATION} ]] || Failed "${LOCATION} doesn't exist, please create ${LOCATION} and try again"
[[ "$1" == "" ]] && Failed "You should call this script with argument as instance_name, exiting..." || KEY_PAIR_NAME="$1_key"

# Check key pair already available
[[ $(${AWS} ec2 describe-key-pairs --key-name ${KEY_PAIR_NAME} --region=${REGION} 2>/dev/null) ]] && Failed "key pair : ${KEY_PAIR_NAME} already exist, exiting..."

# Create key pair in AWS
${AWS} ec2 create-key-pair --region=${REGION} --key-name ${KEY_PAIR_NAME}  --query 'KeyMaterial' --output text > ${LOCATION}${KEY_PAIR_NAME}.pem
[[ $(${AWS} ec2 describe-key-pairs --key-name ${KEY_PAIR_NAME} --region=${REGION}) ]] || Failed "Creating key pair : ${KEY_PAIR_NAME} failed, exiting..."
[[ -f ${LOCATION}${KEY_PAIR_NAME}.pem ]] || Failed "Key pair created in AWS console, but failed to download private key in ${LOCATION}, exiting..."

# Convert .pem file to .ppk file
chmod 400 ${LOCATION}${KEY_PAIR_NAME}.pem
${PUTTYGEN} ${LOCATION}${KEY_PAIR_NAME}.pem -o ${LOCATION}${KEY_PAIR_NAME}.ppk -O private
[[ -f ${LOCATION}${KEY_PAIR_NAME}.ppk ]] || Failed "Converting .pem file to .ppk file failed, exiting..." \
                  && echo "${LOCATION}${KEY_PAIR_NAME}.ppk created succesfully and user can download this and use in putty"


## Next steps
## we can create ec2 instance with below command or using terraform with given key_name from this script
## ${AWS} ec2 run-instances --region=${REGION} --image-id ami-07539a31f72d244e7 \
#        --count 1 \
#        --instance-type t2.micro \
#        --key-name ${KEY_PAIR_NAME} \
#        --security-group-ids sg-063a0f7848a66b311 \
#        --tag-specifications \
#        'ResourceType=instance,Tags=[{Key=Name,Value=$1}]'

