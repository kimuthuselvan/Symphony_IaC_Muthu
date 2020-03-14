#! /bin/bash
###============================================================================
### Script name: terraform.sh
### Script type: Bash script
### Discription: Build and Deploy AWS Services.
### 
### Version: 1.0                                               Date: 2019-12-08
### Author/Developer: Muthuselvan I. Kangeya
### Reviewed by                                                Date:
### Approved by                                                Date:
###============================================================================
### Shell Functions
###============================================================================
_exit () { [ $? -ne 0 ] && exit 1 }

_status () {
  if [ $? -eq 0 ]
  then
    echo "Success."
    return 0
  else
    echo "Failed."
    return 1
  fi
}

_check_dir () {
  echo -e "INFO: Checking directory: $1 ... \c"
  [ ! -d $1 ] && _status || _status
  _exit
}

_check_file () {
  echo -e "INFO: Checking file: $1 ... \c"
  [ ! -f $1 ] && _status || _status
  _exit
}

###============================================================================
### Terraform Functions
###============================================================================
_terraform_init ()
{
  echo -e "\eINFO: Terraform init ... "
  terraform init
}

_terraform_init_with_backend_s3 ()
{
  echo -e "\eINFO: Terraform init ... "
  terraform init	\
	-backend-config "bucket=$S3_BUCKET_NAME"	\
	-backend-config "key=$S3_REMOTE_STATE_FILE"	\
	-backend-config "region=$REGION"	\
	-backend-config "encrypt=true"
}

_terraform_plan ()
{
  echo -e "\nINFO: Terraform plan ... "
  terraform plan -var-file=$TFVARS_FILE
}

_terraform_apply ()
{
  echo -e "\nINFO: Terraform apply ... "
  terraform apply -auto-approve -var-file=$TFVARS_FILE
}

_terraform_destroy ()
{
  echo -e "\nINFO: Terraform destroy ... "
  #terraform destroy -auto-approve -state=$TFSTATE_FILE -var-file=$TFVARS_FILE
  terraform destroy -auto-approve -var-file=$TFVARS_FILE
}

###============================================================================
### Validation
###============================================================================
for DIR in Conductor  Jenkins  Packer  Source  Terraform
do
  _check_dir $DIR
done

echo -e "INFO: Checking OUTPUTFOLDER variable ... \c"
[ -z $OUTPUTFOLDER ] && _status
_exit

echo -e "INFO: Checking WORKSPACE variable ... \c"
[ -z $WORKSPACE ] && _status
_exit

#export TERRAFORM_BASE=$WORKSPACE/Terraform



###============================================================================
### Terraform
###============================================================================
case $ACTION in
build)
  _terraform_init
  #_terraform_init_with_backend_s3
  _terraform_status
  _exit
  _terraform_plan
  _terraform_status
  _exit
  ;;
deploy)
  _terraform_init
  #_terraform_init_with_backend_s3
  _terraform_status
  _exit
  _terraform_plan
  _terraform_status
  _exit
  _terraform_apply
  _terraform_status
  _exit
  ;;
destroy)
  _terraform_destroy
  _terraform_status
  _exit
  ;;
*)
  echo -e "\nSyntax: $0 <build | deploy | destroy>\n"
  ;;
esac  

REPO_PATH=
export TF_LOG=TRACE
export TF_LOG_PATH=${TERRAFORM_BASE}/logs/terraform.`date +'%Y%m%d%H%M%S'`.log
export TF_PLUGIN_CACHE_DIR="$TERRAFORM_BASE/.terraform.d/plugin-cache"






alias terraform=/opt/hashicorp/terraform/bin/terraform
alias packer=/opt/hashicorp/packer/binpacker

export TERRAFORM_BASE=/SecOps/Terraform
export AWS_BUILD_WORKSPACE=$TERRAFORM_BASE/work

ACTION=$1







###============================================================================
### Build and Deployment validation
###============================================================================
_check_file deploy.conf
_exit
TFVARS_FILE="./terraform.tfvars"
_check_file terraform.tfvars
_exit

source ./deploy.conf

if [ "$DEPLOY" != "True" ]
then
  echo "INFO: Unable to start Terraform deployment for SERVICE: $SERVICE_NAME"
  echo "      Check deploy.conf at $AWS_SERVICE_BASE"
  exit 1
fi

ACCOUNT_BASE=$AWS_BUILD_WORKSPACE/$ACCOUNT
AWS_PROFILE=$ACCOUNT_BASE/AWS
#AWS_REGION_BASE=$ACCOUNT_BASE/$REGION
#AWS_SERVICE_BASE=$AWS_REGION_BASE/$SERVICE
#AWS_RESOURCE_BASE=$AWS_SERVICE_BASE/$RESOURCE
#for DIR in "$ACCOUNT_BASE" "$AWS_REGION_BASE" "$AWS_SERVICE_BASE" "$AWS_RESOURCE_BASE"
#do
#  _check_dir $DIR
#  _exit
#done

#TFSTATE_FILE=$AWS_RESOURCE_BASE/terraform.tfstate
#TFVARS_FILE=$AWS_RESOURCE_BASE/terraform.tfvars
#TFBACKEND_FILE=$AWS_RESOURCE_BASE/terraform.tfvars

#_check_file $TFVARS_FILE 
#_exit

_check_file $AWS_PROFILE/aws_profile
_exit
source $AWS_PROFILE/aws_profile

###============================================================================
### Main Script
###============================================================================
#cd $TERRAFORM_BASE/scripts/$SERVICE
#rm -rf .terraform
for TFFILE in `ls $TERRAFORM_BASE/scripts/$RESOURCE_TYPE/*.tf`
do
  FILE_NAME=`basename $TFFILE`
  [ ! -f $FILE_NAME ] && ln -s $TFFILE $FILE_NAME
done



###============================================================================
### End
###============================================================================
