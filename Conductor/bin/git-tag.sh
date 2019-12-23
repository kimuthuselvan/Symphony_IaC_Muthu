#! /bin/bash
###
#LATEST_TAG="Build_`date '+%Y%m%d%H%M%S'`_1"
LATEST_TAG="`git tag -l |grep Jenkins_Build |sort -ur |head -1`"
LATEST_TAG_COUNT=`echo $LATEST_TAG |awk -F_ '{print $4}'`

echo "INFO: Pervious Jenkins Build Tag: $LATEST_TAG"
echo "INFO: Last Jenkins Build Count: $LATEST_TAG_COUNT"

NEW_COUNT=$(( $LATEST_TAG_COUNT + 1 ))
TAG_NAME="Jenkins_Build_`date '+%Y%m%d%H%M%S'`_$NEW_COUNT"

echo "INFO: Applying new Tag: $TAG_NAME"

#cd ${WORKSPACE}
#git tag -a $TAG_NAME -m "$TAG_NAME"
