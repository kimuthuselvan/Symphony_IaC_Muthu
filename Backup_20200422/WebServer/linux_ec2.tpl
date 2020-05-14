#!/bin/bash
yum update -y
yum install -y wget amazon-efs-utils

echo -e "INFO: Downloading RedCloak Agent ... \c"
wget -q https://symphony-software-catalog.s3.amazonaws.com/Agent/Linux/redcloak-1.2.8.0-0.x86_64.rpm
[ $? -ne 0 ] && echo "Failed." || echo "Success."

echo -e "INFO: Installing RedCloak Agent ... \c"
yum localinstall -y redcloak-1.2.8.0-0.x86_64.rpm >/tmp/redcloak-1.2.8.0-0.x86_64.log 2>&1
[ $? -ne 0 ] && echo "Failed." || echo "Success."
cat /tmp/redcloak-1.2.8.0-0.x86_64.log

service redcloak status
/var/opt/secureworks/redcloak/bin/redcloak --check

sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install collectd -y
yum remove epel-release -y

wget -P /tmp/ https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo yum localinstall /tmp/amazon-cloudwatch-agent.rpm -y

wget -P /tmp/ https://symphony-software-catalog.s3.amazonaws.com/Agent/Linux/CloudWatch/linux+config.json
sudo cp /tmp/config.json_linux /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config \
     -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

wget -P /tmp/ https://symphony-software-catalog.s3.amazonaws.com/Agent/Linux/Traps_Linux_installer_4.2.3.713.tar.gz

cd /tmp
tar -zxvf Traps_Linux_installer_4.2.3.713.tar.gz


