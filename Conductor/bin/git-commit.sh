#! /bin/bash
###
echo "INFO: Git commit fils ..."
cd ${WORKSPACE}
git commit -m "Build Number: ${BUILD_NUMBER} - Jenkins commit" -a
[ $? -eq 0 ] && git push
