#! /bin/bash
###============================================================================
### Script name: yaml2tfvars_S3tfstate.sh
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
echo "Current Working Directory: `pwd`"
for DIR in Conductor Packer Source Terraform
do
  _check_dir $DIR
  _exit
done

###============================================================================
### YAML to tfvars process
###============================================================================
CONDUCTOR_BASE=$WORKSPACE/Conductor
SOURCE_BASE=$WORKSPACE/Source
TERRAFORM_BASE=$WORKSPACE/Terraform


TEMPLATE_PATH=$TERRAFORM_BASE/conf
OUTPUTFOLDER=$TERRAFORM_BASE/work

YAML_PATH=$SOURCE_BASE/Symphony/AHS/Storage/S3tfstate
YAML_FILE=$YAML_PATH/Symphony_AHS_AWS_Storage_S3tfstate.yaml
_check_file $YAML_FILE
_exit

TEMPLATE_FILES="$TEMPLATE_PATH/aws_profile.TEMPLATE \
                $TEMPLATE_PATH/aws_S3tfstate.tfvars.TEMPLATE"
#for TFILE in `echo $TEMPLATE_FILES | sed "s/,/ /g"`
#do
#  _check_file $TFILE
#  _exit
#done

echo -e "\n$CONDUCTOR_BASE/bin/yaml2tfvars_S3tfstate.py \
  --yamlfile $YAML_FILE \
  --templatefile $TEMPLATE_FILES \
  --outputfolder $OUTPUTFOLDER\n"

$CONDUCTOR_BASE/bin/yaml2tfvars_S3tfstate.py \
  --yamlfile $YAML_FILE \
  --templatefile $TEMPLATE_FILES \
  --outputfolder $OUTPUTFOLDER

find . -name "*.tfvars" -print

###============================================================================
### End
###============================================================================
