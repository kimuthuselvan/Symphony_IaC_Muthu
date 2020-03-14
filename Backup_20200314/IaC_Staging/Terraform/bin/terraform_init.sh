#! /bin/bash
###============================================================================
### Script name: terraform_init.sh
### Script type: Bash script
### Discription: Terraform init.
### 
### Version: 1.0                                               Date: 2019-12-08
### Author/Developer: Muthuselvan I. Kangeya
### Reviewed by                                                Date:
### Approved by                                                Date:
###============================================================================
### Shell Functions
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
###
###
terraform plan -var-file=$WORKSPACE/Terraform/work/Symphony/AHS/AWS/us-east-1/Storage/S3tfstate/symphony-backend-tfstate-us-east-1/aws_s3tfstate.tfvars