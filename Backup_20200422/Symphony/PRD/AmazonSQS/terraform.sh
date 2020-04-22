#! /bin/bash

export AWS_PROFILE=eh_Adv_aws_kansas_build
#export AWS_PROFILE=eh_adv_aws_main_build
export PATH=$PATH:/awsops/opt/hashicorp/terraform/bin

WARN="\e[93mWarning:\e[39m"
INFO="\e[96mINFO:\e[39m"
SUCCESS="\e[92mSuccess.\e[39m"
FAILED="\e[91mFailed.\e[39m"

_exit () {
  [ $? -ne 0 ] && exit 1
}

_check_status () {
  if [ $? -eq 0 ]
  then
    echo -e "$SUCCESS"
  else
    echo -e "$FAILED"
    cat -n $LOG_FILE
    return 1
  fi
}

_terraform_init () {
  LOG_FILE=terraform.init.log
  echo -e "$INFO Terraform init ... \c"
  terraform init >$LOG_FILE 2>&1
  _check_status
  _exit
}

_terraform_validate () {
  LOG_FILE=terraform.validate.log
  echo -e "$INFO Terraform validate ... \c"
  [ "$ACTION" == "deploy" ] && CMD="terraform validate >$LOG_FILE 2>&1"
  [ "$ACTION" == "update" ] && CMD="terraform validate >>$LOG_FILE 2>&1"
  eval $CMD
  _check_status
  _exit
  #echo "Done."
  #cat -n $LOG_FILE
}

_terraform_plan () {
  LOG_FILE=terraform.plan.log
  echo -e "$INFO Terraform plan ... \c"
  [ "$ACTION" == "deploy" ] && CMD="terraform plan >$LOG_FILE 2>&1"
  [ "$ACTION" == "update" ] && CMD="terraform plan >>$LOG_FILE 2>&1"
  eval $CMD
  _check_status
  _exit
}

_terraform_apply () {
  LOG_FILE=terraform.apply.log
  echo -e "$INFO Terraform apply -auto-approve ... \c"
  [ "$ACTION" == "deploy" ] && CMD="terraform apply -auto-approve >$LOG_FILE 2>&1"
  [ "$ACTION" == "update" ] && CMD="terraform apply -auto-approve >>$LOG_FILE 2>&1"
  eval $CMD
  _check_status
  _exit
}

_terraform_destroy () {
  LOG_FILE=terraform.destroy.log
  echo -e "$INFO Terraform destroy -auto-approve ... \c"
  terraform destroy -auto-approve >$LOG_FILE 2>&1
  _check_status
  _exit
}

_clean () {
  echo -e "$INFO Cleaning all logs, tfstate and .terraform ... \c"
  rm -rf terraform.*.log *tfstate* .terraform .clean
  _check_status
  _exit  
}

ACTION=$1
case $ACTION in
deploy)
  [ -f .clean ] && echo -e "$INFO Please run terraform.sh clean"
  [ -f .clean ] && exit 0
  _terraform_init
  _terraform_validate
  _terraform_plan
  _terraform_apply
  ;;
update)
  LOG_FILE=terraform.validate.log
  [ ! -f terraform.tfstate ] && echo -e "$INFO Please run terraform.sh deploy"
  [ ! -f terraform.tfstate ] && exit 0
  _terraform_validate
  _terraform_plan
  _terraform_apply
  ;;
destroy)
  [ ! -f terraform.tfstate ] && echo -e "$INFO File: terraform.tfstate is missing."
  [ ! -f terraform.tfstate ] && exit 0
  _terraform_destroy
  touch .clean
  ;;
clean)
  [ ! -f .clean ] && echo -e "$INFO Terraform destroy not performed, so unable to clean."
  [ ! -f .clean ] && exit 0
  _clean
  ;;
show)
  terraform show
  ;;
esac

