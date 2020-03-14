#! /bin/bash
###
echo "INFO: Git commit fils ..."
cd ${WORKSPACE}
git commit --dry-run -m "Build Number: ${BUILD_NUMBER} - Jenkins commit" -a
#MODIFIED_FILES_LIST=`git ls-files -m`
#if [ ! -z $MODIFIED_FILES_LIST ]
#then
#  echo -e "INFO: Folloing files will be commit into Git: \n $MODIFIED_FILES_LIST"
#  git commit -m "Build Number: ${BUILD_NUMBER} - Jenkins commit" -a
#  if [ $? -eq 0 ]
#  then
#    git push
#  fi
#fi

