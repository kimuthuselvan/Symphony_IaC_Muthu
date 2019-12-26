#! /bin/bash
###============================================================================
### Script name: conductor.sh
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
### Validation
###============================================================================
for DIR in Conductor  Jenkins  Packer  Source  Terraform
do
  _check_dir $DIR
done

###============================================================================
### Terraform preparation
###============================================================================
export REPO_BASE=`pwd`
export TERRAFORM_WORKSPACE=$REPO_BASE/Terraform/work

for YAML_FILE in `find $REPO_BASE -name "*.yaml" -print`
do
  YAML_FILE_PATH=`dirname $YAML_FILE`
  YAML_FILE_NAME=`basename $YAML_FILE`
  YAML_FILE_PREFIX=`echo $YAML_FILE_NAME |awk -F. '{print $1}'`
  
  ADV_PROJECT=`echo $YAML_FILE_PREFIX |awk -F_ '{print $1}'`
  ADV_CLIENT=`echo $YAML_FILE_PREFIX |awk -F_ '{print $2}'`
  AWS_PROVIDER=`echo $YAML_FILE_PREFIX |awk -F_ '{print $3}'`
  AWS_SERVICE=`echo $YAML_FILE_PREFIX |awk -F_ '{print $4}'`
  AWS_RESOURCE=`echo $YAML_FILE_PREFIX |awk -F_ '{print $5}'`
  
  echo -e "\n"
  echo ===========================================================
  echo "$YAML_FILE_PREFIX"
  echo ===========================================================
  
  #echo ""
  #echo "YAML_FILE_PATH=$YAML_FILE_PATH"
  #echo "YAML_FILE_NAME=$YAML_FILE_NAME"
  #echo "YAML_FILE_PREFIX=$YAML_FILE_PREFIX"
  #echo "ADV_PROJECT=$ADV_PROJECT"
  #echo "ADV_CLIENT=$ADV_CLIENT"
  #echo "AWS_PROVIDER=$AWS_PROVIDER"
  #echo "AWS_SERVICE=$AWS_SERVICE"
  #echo "AWS_RESOURCE=$AWS_RESOURCE"
  #echo ""
  
  export AWS_PROVIDER_PATH=$TERRAFORM_WORKSPACE/$ADV_PROJECT/$ADV_CLIENT/$AWS_PROVIDER
  export OUTPUTFOLDER=$AWS_PROVIDER_PATH
  
  echo ""
  echo "AWS_PROVIDER_PATH=$AWS_PROVIDER_PATH"
  echo "OUTPUTFOLDER=$OUTPUTFOLDER"
  echo ""
  
  mkdir -p $OUTPUTFOLDER
  file $OUTPUTFOLDER
  
  echo -e "\nINFO: Building $AWS_RESOURCE ..."
  echo $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
  $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
done

find $OUTPUTFOLDER -name "*.tfvars" -print >$WORKSPACE/tfvars_file_list.txt
AWS_RESOURCE_S3TFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_s3tfstate.tfvars'`
AWS_RESOURCE_VPCTFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_vpc.tfvars'`
AWS_RESOURCE_SUBNETSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_subnet.tfvars'`
for AWSRESOURCE in $AWS_RESOURCE_S3TFSTATE $AWS_RESOURCE_VPCTFSTATE $AWS_RESOURCE_SUBNETSTATE
do
  if [ ! -z $AWS_RESOURCE_S3TFSTATE ]
  then
    echo "Terraform Build: $AWS_RESOURCE_S3TFSTATE"
  fi
done

###
###
### 


