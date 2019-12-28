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
_exit () {
[ $? -ne 0 ] && exit 1
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
echo "Current Directory: `pwd`"
for DIR in Conductor Packer Source Terraform
do
  _check_dir $DIR
  _exit
done
echo ""
TEMPLATE_PATH=Terraform/conf
TERRAFORM_WORKSPACE=Terraform/work
###============================================================================
### Terraform preparation
###============================================================================
export REPO_BASE=`pwd`
#export TERRAFORM_WORKSPACE=$REPO_BASE/Terraform/work

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
  
  _draw_line
  echo "$YAML_FILE_PREFIX"
  _draw_line
  
  export AWS_PROVIDER_PATH=$TERRAFORM_WORKSPACE/$ADV_PROJECT/$ADV_CLIENT/$AWS_PROVIDER
  export OUTPUTFOLDER=$AWS_PROVIDER_PATH
  
  mkdir -p $OUTPUTFOLDER
  
  echo "INFO: Building $AWS_RESOURCE:"
  echo ""
  #echo $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
  #echo ""
  #$REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.sh $YAML_FILE
  #echo ""
  #TEMPLATE_PATH=$REPO_BASE/Terraform/conf
  for TFILE in "$TEMPLATE_PATH/aws_profile.TEMPLATE" "$TEMPLATE_PATH/aws_$AWS_RESOURCE.tfvars.TEMPLATE"
  do
    _check_file $TFILE
  done
  if [ "$AWS_RESOURCE" == "Network" ]
  then
    TEMPLATE_FILES="$TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_vpc.tfvars.TEMPLATE,$TEMPLATE_PATH/aws_subnet.tfvars.TEMPLATE"
  else
    TEMPLATE_FILES="$TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_$AWS_RESOURCE.tfvars.TEMPLATE"
  fi
  echo "$REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.py \
	--buildfile $YAML_FILE \
	--templatefile $TEMPLATE_FILES \
	--outputfolder $OUTPUTFOLDER"  
  $REPO_BASE/Conductor/bin/yaml2tfvars_$AWS_RESOURCE.py \
	--buildfile $YAML_FILE \
	--templatefile $TEMPLATE_FILES \
	--outputfolder $OUTPUTFOLDER
  echo ""
done

_draw_line
echo "INFO: List of Terraform variable file(s)"
_draw_line
find $OUTPUTFOLDER -name "*.tfvars" -print >$WORKSPACE/tfvars_file_list.txt
AWS_RESOURCE_S3TFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_s3tfstate.tfvars'`
AWS_RESOURCE_VPCTFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_vpc.tfvars'`
AWS_RESOURCE_SUBNETSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_subnet.tfvars'`
for AWSRESOURCE in $AWS_RESOURCE_S3TFSTATE $AWS_RESOURCE_VPCTFSTATE $AWS_RESOURCE_SUBNETSTATE
do
  if [ ! -z $AWSRESOURCE ]
  then
    echo "Terraform Build: $AWSRESOURCE"
  fi
done
_draw_line

###
###
### 