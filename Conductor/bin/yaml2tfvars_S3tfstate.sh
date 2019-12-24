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

YAML_FILE=$1
_check_file $YAML_FILE
_exit

cd $REPO_BASE
for DIR in Conductor Packer Source Terraform
do
  _check_directory $DIR
  _exit
done

TEMPLATE_PATH=$REPO_BASE/Terraform/conf
echo "$REPO_BASE/Conductor/bin/yaml2tfvars_S3tfstate.py	\
	--buildfile $YAML_FILE	\
	--templatefile $TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_s3tfstate.tfvars.TEMPLATE	\
	--outputfolder $TERRAFORM_WORKSPACE"
$REPO_BASE/Conductor/bin/yaml2tfvars_S3tfstate.py	\
	--buildfile $YAML_FILE	\
	--templatefile $TEMPLATE_PATH/aws_profile.TEMPLATE,$TEMPLATE_PATH/aws_s3tfstate.tfvars.TEMPLATE	\
	--outputfolder $TERRAFORM_WORKSPACE

#git commit -m "Build update yaml" $YAML_FILE
#git push
