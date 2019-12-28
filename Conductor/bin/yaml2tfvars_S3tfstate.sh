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
for TFILE in `echo $TEMPLATE_FILES | sed "s/,/ /g"`
do
  _check_file $TFILE
  _exit
done

echo -e "\nConductor/bin/yaml2tfvars_S3tfstate.py --buildfile $WORKSPACE/$YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $WORKSPACE/$OUTPUTFOLDER\n"
Conductor/bin/yaml2tfvars_S3tfstate.py --buildfile $WORKSPACE/$YAML_FILE --templatefile $TEMPLATE_FILES --outputfolder $WORKSPACE/$OUTPUTFOLDER

find . -name "*.tfvars" -print

#find $OUTPUTFOLDER -name "*.tfvars" -print >$WORKSPACE/tfvars_file_list.txt
#AWS_RESOURCE_S3TFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_s3tfstate.tfvars'`
#AWS_RESOURCE_VPCTFSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_vpc.tfvars'`
#AWS_RESOURCE_SUBNETSTATE=`cat $WORKSPACE/tfvars_file_list.txt |grep 'aws_subnet.tfvars'`
#for AWSRESOURCE in $AWS_RESOURCE_S3TFSTATE $AWS_RESOURCE_VPCTFSTATE $AWS_RESOURCE_SUBNETSTATE
#do
#  if [ ! -z $AWSRESOURCE ]
#  then
#    echo "Terraform Build: $AWSRESOURCE"
#  fi
#done

