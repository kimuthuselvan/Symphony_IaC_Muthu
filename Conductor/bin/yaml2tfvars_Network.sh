#! /bin/bash
###============================================================================
### Script name: yaml2tfvars_Network.sh
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
### YAML to tfvars process
###============================================================================
CONDUCTOR_BASE=Conductor
SOURCE_BASE=Source
TERRAFORM_BASE=Terraform
TEMPLATE_PATH=$TERRAFORM_BASE/conf

for YAML_FILE in `find $SOURCE_BASE -name "*_Network.yaml" -print`
do
  YAML_FILE_NAME=`basename $YAML_FILE`
  YAML_FILE_PATH=`dirname $YAML_FILE`
  YAML_FILE_PREFIX=`echo $YAML_FILE_NAME |awk -F. '{print $1}'`
  echo "YAML_FILE_PREFIX:$YAML_FILE_PREFIX"
  ADV_PROJECT=`echo $YAML_FILE_PREFIX |awk -F_ '{print $1}'`
  echo "ADV_PROJECT=$ADV_PROJECT"
  ADV_CLIENT=`echo $YAML_FILE_PREFIX |awk -F_ '{print $2}'`
  echo "ADV_CLIENT=$ADV_CLIENT"
  AWS_PROVIDER=`echo $YAML_FILE_PREFIX |awk -F_ '{print $3}'`
  echo "AWS_PROVIDER=$AWS_PROVIDER"
  AWS_SERVICE=`echo $YAML_FILE_PREFIX |awk -F_ '{print $4}'`
  echo "AWS_SERVICE=$AWS_SERVICE"
  AWS_RESOURCE=`echo $YAML_FILE_PREFIX |awk -F_ '{print $5}'`
  echo "AWS_RESOURCE=$AWS_RESOURCE"
     
  OUTPUTFOLDER=$TERRAFORM_BASE/work/$ADV_PROJECT/$ADV_CLIENT
  mkdir -p $OUTPUTFOLDER
  
  cp -f $SOURCE_BASE/$ADV_PROJECT/$ADV_CLIENT/aws_profile $OUTPUTFOLDER/
    
  _draw_line
  echo "$YAML_FILE_PREFIX"
  _draw_line
  
  TEMPLATE_FILES=$TEMPLATE_PATH/aws_vpc.tfvars.TEMPLATE,$TEMPLATE_PATH/aws_subnet.tfvars.TEMPLATE
  
  echo -e "\nCommand: $CONDUCTOR_BASE/bin/yaml2tfvars_S3tfstate.py \
    --yamlfile $YAML_FILE \
    --templatefile $TEMPLATE_FILES \
    --outputfolder $OUTPUTFOLDER\n"
  
  $CONDUCTOR_BASE/bin/yaml2tfvars_S3tfstate.py \
    --yamlfile $YAML_FILE \
    --templatefile $TEMPLATE_FILES \
    --outputfolder $OUTPUTFOLDER
  
  _draw_line
  find $WORKSPACE -name "aws_S3tfstate.tfvars" -print >$WORKSPACE/${ADV_CLIENT}_Network.build
done

###============================================================================
### End
###============================================================================
