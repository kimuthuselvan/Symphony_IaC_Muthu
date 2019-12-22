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



cd ../..
BASE_DIR=`pwd`
TEMPLATE_DIR="$BASE_DIR/Terraform/conf"
for DIR in Conductor Packer Source Terraform
do
  _check_directory $DIR
  _exit
done

###
###
###
for YAML_FILE in `find . -name "*.yaml" -print`
do
  echo -e "\n"
  FILE_NAME=`basename $YAML_FILE`
  DIR_PATH=`dirname $YAML_FILE`
  RESOURCE_TYPE=`echo $FILE_NAME |awk -F. '{print $1}' |awk -F_ '{print $NF}'`
  BUILDER=$BASE_DIR/Conductor/bin/yaml2tfvars_$RESOURCE_TYPE.py
  cd $DIR_PATH
  echo "INFO: Building yaml to tfvars - $BASE_DIR/$YAML_FILE"
  echo "$BUILDER --buildfile $FILE_NAME --templatefile $TEMPLATE_DIR/aws_profile.TEMPLATE,$TEMPLATE_DIR/aws_vpc.TEMPLATE,$TEMPLATE_DIR/aws_subnet.TEMPLATE"
  $BUILDER --buildfile $FILE_NAME --templatefile $TEMPLATE_DIR/aws_profile.TEMPLATE,$TEMPLATE_DIR/aws_vpc.tfvars.TEMPLATE,$TEMPLATE_DIR/aws_subnet.tfvars.TEMPLATE
  #$BUILDER --load $FILE_NAME
  cd $BASE_DIR
done
###
###
###  
