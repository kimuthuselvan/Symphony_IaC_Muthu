#! /bin/bash
###============================================================================
### Script name: terraform_S3tfstate.sh
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
_exit () {
  [ $? -ne 0 ] && exit 1
}

_loop_exit () {
  [ $? -ne 0 ] && break
  LOOP_STATUS=1
}

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
  if [ -d $1 ]
  then
    echo "Done."
    return 0
  else
    echo "Failed."
    return 1
  fi
}

_check_file () {
  echo -e "INFO: Checking file: $1 ... \c"
  if [ -f $1 ]
  then
    echo "Done."
    return 0
  else
    echo "Failed."
    return 1
  fi
}

_draw_line () {
L="0"
while [ $L -lt 80 ]
  do
    echo -e "=\c"
    L=$[$L+1]
  done
echo ""
}

###============================================================================
### Validation
###============================================================================
echo "Current Working Directory: `pwd`"
for DIR in Conductor Packer Source Terraform
do
  _check_dir $DIR
  _exit
done

###============================================================================
### Terraform Deploy (or) Destroy
###============================================================================
CONDUCTOR_BASE=$WORKSPACE/Conductor
SOURCE_BASE=$WORKSPACE/Source
TERRAFORM_BASE=$WORKSPACE/Terraform
TEMPLATE_PATH=$TERRAFORM_BASE/conf

echo "INFO: CWD: `pwd`"
find $WORKSPACE -name "*.tfvars" -print

LOOP_STATUS=0
for TFVARS in `find $WORKSPACE -name "*.tfvars" -print`
do
  if [ ! -z $TFVARS ]
  then
    TF_BUILD_DIR=`dirname $TFVARS`
	[ ! -f ../../../../aws_profile ] && exit 1
	source ../../../../aws_profile
    cd $TERRAFORM_BASE/script/AWS/Storage/S3tfstate
    rm -rf '.terraform'
    echo -e "INFO: Processing terraform init ... \c"
    terraform init
    _status
    _loop_exit
    echo -e "INFO: Processing terraform plan ... \c"
    terraform plan -var-file=$TFVARS
    _status
    _loop_exit
    echo -e "INFO: Processing terraform apply ... \c"
    terraform apply -auto-approve -var-file=$TFVARS
    _status
    _loop_exit
	mv terraform.tfstate $TF_BUILD_DIR/
  else
    echo "INFO: Nothing to do"
  fi
done
[ $LOOP_STATUS -eq 0 ] && exit 0 || exit 1

###============================================================================
### End
###============================================================================

