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

#YAML_FILE=$1
#_check_file $YAML_FILE
#_exit
#
#cd $REPO_BASE
#for DIR in Conductor Packer Source Terraform
#do
#  _check_directory $DIR
#  _exit
#done
#
#TEMPLATE_PATH=$REPO_BASE/Terraform/conf
#$REPO_BASE/Conductor/bin/yaml2tfvars_Network.py	\#
#	--buildfile $YAML_FILE	\
#	--templatefile $TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_vpc.tfvars.TEMPLATE,$TEMPLATE_PATH/aws_subnet.tfvars.TEMPLATE	\
#	--outputfolder $OUTPUTFOLDER

YAML_FILE=$WORKSPACE/Source/Symphony/AHS/Network/Network/Symphony_AHS_AWS_Network_Network.yaml
_check_file $YAML_FILE
_exit

TEMPLATE_PATH=$WORKSPACE/Terraform/conf
OUTPUTFOLDER=$WORKSPACE/Terraform/work

TEMPLATE_FILES=$TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_vpc.tfvars.TEMPLATE,$TEMPLATE_PATH/aws_subnet.tfvars.TEMPLATE
for TFILE in `echo $TEMPLATE_FILES | sed "s/,/ /g"`
do
  _check_file $TFILE
  _exit
done

echo "$WORKSPACE/Conductor/bin/yaml2tfvars_Network.py --buildfile $YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $OUTPUTFOLDER"
$WORKSPACE/Conductor/bin/yaml2tfvars_Network.py --buildfile $YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $OUTPUTFOLDER
