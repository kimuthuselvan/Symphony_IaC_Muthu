#!/bin/bash
yum update -y
yum install -y wget amazon-efs-utils

echo -e "INFO: Downloading RedCloak Agent ... \c"
wget -q http://jenkins-awsops-prod.sym-adv.com:8000/redcloak-1.2.8.0-0.x86_64.rpm
[ $? -ne 0 ] && echo "Failed." || echo "Success."

echo -e "INFO: Installing RedCloak Agent ... \c"
yum localinstall -y redcloak-1.2.8.0-0.x86_64.rpm >/tmp/redcloak-1.2.8.0-0.x86_64.log 2>&1
[ $? -ne 0 ] && echo "Failed." || echo "Success."
cat /tmp/redcloak-1.2.8.0-0.x86_64.log

service redcloak status
/var/opt/secureworks/redcloak/bin/redcloak --check

mkdir -p /mnt/eft_efs

mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /mnt/eft_efs

echo "${efs_dns_name}:/ /mnt/eft_efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >>/etc/fstab

