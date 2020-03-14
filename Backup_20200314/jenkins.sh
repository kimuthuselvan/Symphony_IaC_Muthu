#! /bin/bash
###============================================================================
### Script name: jenkins.sh
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
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ restart
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ safe-restart
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ shutdown
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ safe-shutdown
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ quiet-down
#$ java -jar jenkins-cli.jar -s http://<jenkins-server>/ cancel-quiet-down
###
BASE_PATH=/awsops
export JAVA_HOME=$BASE_PATH/opt/java/jdk1.8.0_231
export JENKINS_HOME=$BASE_PATH/Jenkins/Master-http

PORT=8080

LOGFILE="$JENKINS_HOME/logs/$HOSTNAME.jenkins.log"

#export JENKINS_URL="https://$HOSTNAME:$PORT"

ACTION=$1

###============================================================================
### Validating Self Signed SSL Certificate
###============================================================================
case $ACTION in
  --start)
    echo -e "INFO: Starting Jenkins Server ... \c"
    nohup $JAVA_HOME/bin/java \
      -jar $JENKINS_HOME/webapps/jenkins.war \
      --httpPort=$PORT > $LOGFILE 2>&1 &
    echo "Done."
    echo "INFO: Jenkins server log at $LOGFILE"
    echo -e "\nhttp://$HOSTNAME:$PORT\n"
    #echo -e "\nhttp://awsops-jenkins-master-prod.sym-adv.com:$PORT\n"
    ;;
  --stop)
    echo -e "INFO: Jenkins server will shutdown safely ... \c"
    $JAVA_HOME/bin/java -jar $JENKINS_HOME/war/WEB-INF/jenkins-cli.jar \
                        -auth 'jenkins:0n3J3nk!n$' \
                        -s http://ip-10-126-64-97.ec2.internal:8080/ safe-shutdown
    echo "Done."
    ;;
  *)
    echo -e "\nSyntax: $0 <--start | --stop>\n"
    ;;
esac
###============================================================================
### Jenkins URL
###============================================================================
