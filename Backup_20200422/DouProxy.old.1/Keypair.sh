#! /bin/bash
###
###
###
WARN="\e[93mWarning:\e[39m"
INFO="\e[96mINFO:\e[39m"
SUCCESS="\e[92mSuccess.\e[39m"
FAILED="\e[91mFailed.\e[39m"

REGION=`cat ./terraform.tfvars |grep region_name |awk -F= '{print $2}'`
KEY=`cat ./terraform.tfvars |grep key_name |awk -F= '{print $2}'`

REGION_NAME=`echo -e $REGION |sed -e 's/"//g'`
KEY_NAME=`echo -e $KEY |sed -e 's/"//g'`

ACTION=$1

_exit () {
  [ $? -ne 0 ] && exit 1
}

_check_status () {
  if [ $? -eq 0 ]
  then
    echo -e "$SUCCESS"
  else
    echo -e "$FAILED"
    return 1
  fi
}

case $ACTION in
deploy)
  echo -e "$INFO Generating new Keypair for EC2 ... \c"
  aws ec2 create-key-pair \
    --region=${REGION_NAME} \
    --key-name ${KEY_NAME} \
    --query 'KeyMaterial' \
    --output text >${KEY_NAME}.pem
  _check_status
  _exit
  echo -e "$INFO Generating Putty Private Key ... \c"
  puttygen ${KEY_NAME}.pem -O private -o ${KEY_NAME}.ppk
  _check_status
  _exit
  ;;
destroy)
  echo -e "$WARN Destroying Keypair for EC2 ... \c"
  aws ec2 delete-key-pair \
    --region=${REGION_NAME} \
    --key-name ${KEY_NAME}
  [ $? -eq 0 ] && rm ${KEY_NAME}.p* || return 1
  _check_status
  _exit
  ;;
esac
