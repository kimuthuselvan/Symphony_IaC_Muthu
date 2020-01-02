#! /bin/bash
###
SOURCE_PATH=${WORKSPACE}
TARGET_PATH=/awsops/WorkSpace/IaC_Staging
if [ ! -d $TARGET_PATH ]
then
  echo "ERROR: Stage path: $TARGET_PATH is missing"
  exit 1
fi

rsync -v -c -r ${WORKSPACE}/* $TARGET_PATH/
if [ $? -ne 0 ]
then
  exit 1
fi
chmod -R 744 $TARGET_PATH/*
if [ $? -ne 0 ]
then
  exit 1
fi
