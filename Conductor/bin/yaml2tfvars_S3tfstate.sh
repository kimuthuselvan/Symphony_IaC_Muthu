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

YAML_FILE=$WORKSPACE/Source/Symphony/AHS/Storage/S3tfstate/Symphony_AHS_AWS_Storage_S3tfstate.yaml
_check_file $YAML_FILE
_exit

TEMPLATE_PATH=$WORKSPACE/Terraform/conf
OUTPUTFOLDER=$WORKSPACE/Terraform/work

TEMPLATE_FILES=$TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_S3tfstate.tfvars.TEMPLATE
for TFILE in `echo $TEMPLATE_FILES | sed "s/,/ /g"`
do
  _check_file $TFILE
  _exit
done

echo -e "\n$WORKSPACE/Conductor/bin/yaml2tfvars_S3tfstate.py --yamlfile $YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $OUTPUTFOLDER\n"
$WORKSPACE/Conductor/bin/yaml2tfvars_S3tfstate.py --yamlfile $YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $OUTPUTFOLDER

find . -name "*.tfvars" -print



