#! /bin/bash
#wget -q https://redcloak.secureworks.com/packages/3a3bae58-f566-48ec-a472-bee5766f150f/redcloak-1.2.8.0-0.x86_64.rpm

echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

echo -e "INFO: Downloading RedCloak Agent ... \c"
sudo wget -q http://jenkins-awsops-prod.sym-adv.com:8000/redcloak-1.2.8.0-0.x86_64.rpm
[ $? -ne 0 ] && echo "Failed." || echo "Success."

echo -e "INFO: Installing RedCloak Agent ... \c"
sudo yum localinstall -y redcloak-1.2.8.0-0.x86_64.rpm >/tmp/redcloak-1.2.8.0-0.x86_64.log 2>&1
[ $? -ne 0 ] && echo "Failed." || echo "Success."
cat /tmp/redcloak-1.2.8.0-0.x86_64.log

sudo service redcloak status
sudo /var/opt/secureworks/redcloak/bin/redcloak --check

