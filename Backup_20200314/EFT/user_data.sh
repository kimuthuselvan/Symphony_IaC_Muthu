#!/bin/env bash

set -euo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

touch /home/ec2-user/success
touch /tmp/Selvan.txt
sudo touch /tmp/Muthu.txt

