#! /bin/bash
###============================================================================
### Script name: jenkins_setup.sh
### Script type: Shell (Bash) script
### Description:
###
###
###
### Developed by Muthuselvan I. Kangeya (kimuthuselvan@gmail.com)
### Version 1.0                                                Date: 2019-12-24
### Reviewed by                    Date:
### Approved by                    Date:
###============================================================================
### Global variables
###============================================================================
BASE_PATH=/awsops
export JAVA_HOME=$BASE_PATH/opt/java/jdk1.8.0_231
export JENKINS_HOME=$BASE_PATH/Jenkins/Master-http

JENKINS_WAR_URL=http://mirrors.jenkins.io/war-stable/latest/jenkins.war

###============================================================================
### Validation for installation
###============================================================================
echo -e "INFO: Creating directory structure ... \c"
[ -d $JENKINS_HOME ] || mkdir -p $JENKINS_HOME
cd $JENKINS_HOME
for DIR in bin conf lib logs webapps
do
  [ -d $DIR ] || mkdir $DIR
done
echo "Done."
find $JENKINS_HOME -print

###============================================================================
### Validation for installation
###============================================================================
cd webapps
if [ -f jenkins.war ]
then
  echo "INFO: Jenkins Server already installed."
else
  echo -e "INFO: Downloading jenkins.war ... \c"
  wget -q -o $JENKINS_HOME/logs/wget.log $JENKINS_WAR_URL
  [ $? -eq 0 ] && echo "Success." || echo "Failed."
fi

