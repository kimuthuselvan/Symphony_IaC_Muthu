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
    echo "       Please contact Administrator."
    return 1
  fi
}
 

CWD=`pwd`
PRJ_DIR="../.."
for DIR in Conductor Packer Source Terraform
do
  _check_directory
  _exit
done



