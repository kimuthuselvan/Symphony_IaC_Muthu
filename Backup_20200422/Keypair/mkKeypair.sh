#! /bin/bash 
###
###
###
WARN="\e[93mWarning:\e[39m"
INFO="\e[96mINFO:\e[39m"
SUCCESS="\e[92mSuccess.\e[39m"
FAILED="\e[91mFailed.\e[39m"

export AWS_PROFILE=eh_Adv_aws_kansas_build

source ./terraform.tfvars

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
  echo -e "$INFO Generating new Keypair for EC2:$ec2_name ... \c"
  #aws ec2 create-key-pair --region=${region_name} --key-name ${ec2_name} --query 'KeyMaterial' --output text > ${ec2_name}.pem
  aws ec2 create-key-pair --region=${region_name} --key-name ${ec2_name} --output text >${ec2_name}.pem
  _check_status
  _exit
  ;;
destroy)
  echo -e "$WARN Destroying Keypair for EC2:$ec2_name ... \c"
  aws ec2 delete-key-pair --region=${region_name} --key-name ${ec2_name}
  [ $? -eq 0 ] && rm ${ec2_name}.pem || return 1
  _check_status
  _exit
  ;;
esac

#aws ec2 create-key-pair \
#  --region=us-east-1 \
#  --key-name my-test-key \
#  --query 'KeyMaterial' \
#  --output text > my-test-key.pem

