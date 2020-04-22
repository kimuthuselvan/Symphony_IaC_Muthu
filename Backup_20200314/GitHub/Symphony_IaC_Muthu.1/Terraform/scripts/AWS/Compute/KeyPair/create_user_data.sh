#!/usr/bin/sh
# this is dependant script for create_new_keypair_for_existing_instance.sh to create user_data

USER="$1"
pub_key="$(ssh-keygen -y -f $2)"

cat << EOF
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [users-groups, once]
users:
  - name: ${USER}
    ssh-authorized-keys: 
    - ${pub_key}
EOF

