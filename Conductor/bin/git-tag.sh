#! /bin/bash
###
LATEST_TAG="Dev_20191220120610_1"
#LATEST_TAG="`git tag -l |head -1`"
LATEST_TAG_COUNT=`echo $LATEST_TAG |awk -F_ '{print $3}'`
echo $LATEST_TAG_COUNT
NEW_COUNT=$(( $LATEST_TAG_COUNT + 1 ))

echo $NEW_COUNT
TAG_NAME="Dev_`date '+%Y%m%d%H%M%S'`_$NEW_COUNT"
echo $TAG_NAME
#TAG_NAME="Build_`date '+%Y%m%d%H%M%S'`_$COUNT"

#cd ${WORKSPACE}

#git tag -a $TAG_NAME -m "$TAG_NAME"

