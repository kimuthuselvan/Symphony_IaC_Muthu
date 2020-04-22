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

_terraform_init () {
  LOG_FILE=terraform.init.log
  echo -e "INFO: Terraform init ... \c"
  terraform init >terraform.init.log 2>&1
  _check_status
  _exit
}

_terraform_validate () {
  LOG_FILE=terraform.validate.log
  echo -e "INFO: Terraform validate ... \c"
  terraform validate >terraform.validate.log 2>&1
  _check_status
  _exit
}

_terraform_plan () {
  LOG_FILE=terraform.plan.log
  echo -e "INFO: Terraform plan ... \c"
  terraform plan >terraform.plan.log 2>&1
  _check_status
  _exit
}

_terraform_apply () {
  LOG_FILE=terraform.apply.log
  echo -e "INFO: Terraform apply -auto-approve ... \c"
  terraform apply -auto-approve >terraform.apply.log 2>&1
  _check_status
  _exit
}

_terraform_destroy () {
  LOG_FILE=terraform.destroy.log
  echo -e "INFO: Terraform destroy -auto-approve ... \c"
  terraform destroy -auto-approve >terraform.destroy.log 2>&1
  _check_status
  _exit
}

_clean () {
  [ ! -f .clean ] && echo "INFO: Terraform destroy not performed, so unable to clean."
  [ ! -f .clean ] && exit 0
  echo -e "INFO: Cleaning all logs, tfstate and .terraform ... \c"
  rm -rf terraform.*.log terraform.tfstate terraform.tfstate.backup .terraform
  _check_status
  _exit  
}

export AWS_PROFILE=eh_Adv_aws_kansas_build
export PATH=$PATH:/awsops/opt/hashicorp/terraform/bin

ACTION=$1
case $ACTION in
deploy)
  _terraform_init
  _terraform_validate
  _terraform_plan
  _terraform_apply
  ;;
update)
  LOG_FILE=terraform.validate.log
  echo -e "INFO: Terraform validate ... \c"
  echo -e "\n`date`\n" >>terraform.validate.log 2>&1
  terraform validate >>terraform.validate.log 2>&1
  _check_status
  _exit
  LOG_FILE=terraform.plan.log
  echo -e "INFO: Terraform plan ... \c"
  echo -e "\n`date`\n" >>terraform.validate.log 2>&1
  terraform plan >>terraform.plan.log 2>&1
  _check_status
  _exit
  LOG_FILE=terraform.apply.log
  echo -e "INFO: Terraform apply -auto-approve ... \c"
  echo -e "\n`date`\n" >>terraform.validate.log 2>&1
  terraform apply -auto-approve >>terraform.apply.log 2>&1
  _check_status
  _exit
  ;;
destroy)
  _terraform_destroy
  touch .clean
  ;;
clean)
  _clean
  ;;
show)
  terraform show
  ;;
esac

