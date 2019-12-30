#! /bin/bash
###

STAGE_PATH=/awsops/WorkSpace/GitHub/Symphony_IaC_Muthu
if [ ! -d $STAGE_PATH ]
then
  echo "ERROR: Stage path (/SecOps) is missing"
  exit 1
fi

SOURCE_PATH=${WORKSPACE}
TARGET_PATH=$STAGE_PATH
rsync -v -c -r ${WORKSPACE}/* $TARGET_PATH/
if [ $? -ne 0 ]
then
  exit 1
fi
chmod -R 774 $TARGET_PATH/*
if [ $? -ne 0 ]
then
  exit 1
fi
