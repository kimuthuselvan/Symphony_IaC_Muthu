#!/bin/bash
#AWS_S3='https://s3.amazonaws.com'
#SYMPHONY_SOFTWARE_CATALOG_S3='https://symphony-software-catalog.s3.amazonaws.com'
sudo mkdir -p /etc/ecs
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

sudo yum install -y wget unzip zip

## RedClock Agent Installation ##
sudo wget -P /tmp/ https://symphony-software-catalog.s3.amazonaws.com/Agent/Linux/redcloak-1.2.8.0-0.x86_64.rpm
sudo yum localinstall -y /tmp/redcloak-1.2.8.0-0.x86_64.rpm
sudo service redcloak status
sudo /var/opt/secureworks/redcloak/bin/redcloak --check

## EPEL Repository ##
sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install collectd -y
yum remove epel-release -y

## CloudWatch Agent Installation ##
wget -P /tmp/ https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo yum localinstall /tmp/amazon-cloudwatch-agent.rpm -y
wget -P /tmp/ https://symphony-software-catalog.s3.amazonaws.com/Agent/Linux/CloudWatch/linux+config.json
sudo cp /tmp/linux+config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config \
     -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

