#! /bin/bash
###
#export TERRAFORM_WORKSPACE=$WORKSPACE/Terraform/work

_exit ()
{
  [ $? -ne 0 ] && exit 1
}

_check_directory ()
{
  if [ ! -d $1 ]
  then
    echo "ERROR: The Directory: $1 is missing."
    echo "       Please contact Administrator."
    return 1
  fi
}

for DIR in Conductor Packer Source Terraform
do
  _check_directory $DIR
  _exit
done

export REPO_BASE=`pwd`
export TERRAFORM_WORKSPACE=$REPO_BASE/Terraform/work

###
###
###

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
  
  echo ""
  echo "YAML_FILE_PATH=$YAML_FILE_PATH"
  echo "YAML_FILE_NAME=$YAML_FILE_NAME"
  echo "YAML_FILE_PREFIX=$YAML_FILE_PREFIX"
  echo "ADV_PROJECT=$ADV_PROJECT"
  echo "ADV_CLIENT=$ADV_CLIENT"
  echo "AWS_PROVIDER=$AWS_PROVIDER"
  echo "AWS_SERVICE=$AWS_SERVICE"
  echo "AWS_RESOURCE=$AWS_RESOURCE"
  echo ""
  
  AWS_PROVIDER_PATH=$TERRAFORM_WORKSPACE/$ADV_PROJECT/$ADV_CLIENT/$AWS_PROVIDER
  OUTPUTFOLDER=$AWS_PROVIDER_PATH
  
  echo ""
  echo "AWS_PROVIDER_PATH=$AWS_PROVIDER_PATH"
  echo "OUTPUTFOLDER=$OUTPUTFOLDER"
  echo ""
  
  #RESOURCE_TYPE=`echo $YAML_FILE_NAME |awk -F. '{print $1}' |awk -F_ '{print $NF}'`
  echo -e "\nINFO: Building $AWS_RESOURCE ..."
  echo $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
  $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
done
###
###
### 


