#! /bin/bash
###
_exit ()
{
  [ $? -ne 0 ] && exit 1
}

_check_directory ()
{
  if [ ! -d $1 ]
  then
    echo "ERROR: The Directory: $1 is missing."
    return 1
  fi
}

_check_file ()
{
  if [ ! -f $1 ]
  then
    echo "ERROR: The file: $1 is missing."
	return 1
  fi
}

for DIR in Conductor Packer Source Terraform
do
  _check_directory $DIR
  _exit
done

YAML_FILE=Source/Symphony/AHS/Storage/S3tfstate/Symphony_AHS_AWS_Storage_S3tfstate.yaml
_check_file $YAML_FILE
_exit

TEMPLATE_PATH=Terraform/conf
OUTPUTFOLDER=Terraform/work

TEMPLATE_FILES=$WORKSPACE/$TEMPLATE_PATH/aws_profile.TEMPLATE,$WORKSPACE/$TEMPLATE_PATH/aws_S3tfstate.tfvars.TEMPLATE
for TFILE in $(echo $TEMPLATE_FILES | sed "s/,/ /g")
do
  _check_file $TFILE
  _exit
done

echo "Conductor/bin/yaml2tfvars_S3tfstate.py --buildfile $WORKSPACE/$YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $WORKSPACE/$OUTPUTFOLDER"
Conductor/bin/yaml2tfvars_S3tfstate.py --buildfile $WORKSPACE/$YAML_FILE --templatefile $WORKSPACE/$TEMPLATE_FILES --outputfolder $WORKSPACE/$OUTPUTFOLDER

