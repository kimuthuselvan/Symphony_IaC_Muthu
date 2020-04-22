#!/bin/bash
sed -i 's|SELINUX=enforcing|SELINUX=disabled|g' /etc/selinux/config
setenforce 0

cd /tmp
sudo yum install httpd wget -y
wget -r -l 5  -P /tmp/mysite http://${bucket_url}/

sudo cp -pR /tmp/mysite/${bucket_url}/* /var/www/html/
sudo systemctl restart httpd
sudo systemctl enable httpd

