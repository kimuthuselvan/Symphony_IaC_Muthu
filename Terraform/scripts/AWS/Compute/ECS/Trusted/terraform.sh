#! /bin/bash

_exit () {
  [ $? -ne 0 ] && exit 1
}

_check_status () {
  if [ $? -eq 0 ]
  then
    echo "Success."
  else
    echo "Failed."
    cat $LOG_FILE
    return 1
  fi
}

export AWS_PROFILE=eh_Adv_aws_kansas_build
export PATH=$PATH:/awsops/opt/hashicorp/terraform/bin

ACTION=$1
case $ACTION in
deploy)
  LOG_FILE=terraform.init.log
  echo -e "INFO: Terraform init ... \c"
  terraform init >terraform.init.log 2>&1
  _check_status
  _exit
  LOG_FILE=terraform.validate.log
  echo -e "INFO: Terraform validate ... \c"
  terraform validate >terraform.validate.log 2>&1
  _check_status
  _exit
  LOG_FILE=terraform.plan.log
  echo -e "INFO: Terraform plan ... \c"
  terraform plan >terraform.plan.log 2>&1 
  _check_status
  _exit
  LOG_FILE=terraform.apply.log
  echo -e "INFO: Terraform apply -auto-approve ... \c"
  terraform apply -auto-approve >terraform.apply.log 2>&1
  _check_status
  _exit
  ;;
destroy)
  LOG_FILE=terraform.destroy.log
  echo -e "INFO: Terraform destroy -auto-approve ... \c"
  terraform destroy -auto-approve >terraform.destroy.log 2>&1
  _check_status
  _exit
  ;;
clean)
  echo -e "INFO: Cleaning all logs, tfstate and .terraform ... \c"
  rm -rf terraform.*.log terraform.tfstate terraform.tfstate.backup .terraform
  _check_status
  _exit
  ;;
esac

