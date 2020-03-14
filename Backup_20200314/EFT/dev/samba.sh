#!/bin/bash -e


#### For samba share and samba user
USER="sambauser"
GROUP="sambashare"
PASSWD="sambapasswd"
samba_config="/etc/samba/smb.conf"
share_name="Myshare"
Filesystem_to_share="/mnt/testeft"

#### For sambaadmin
ADMIN_USER="sambaadmin"
ADMIN_PASSWD="adminpasswd"
SUDO_RULES="$(cat <<-EOF
Cmnd_Alias RULES = /usr/bin/vi /etc/samba/smb.conf, /usr/bin/systemctl restart smb.service
${ADMIN_USER} ALL=(root) NOPASSWD: RULES
EOF
)"
####
PATH=$PATH:/usr/sbin

sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo "### Add admin user ###"
sudo useradd -c "samba admin" ${ADMIN_USER}
echo ${ADMIN_PASSWD} |sudo passwd ${ADMIN_USER} --stdin
echo "${SUDO_RULES}" | sudo tee -a /etc/sudoers
echo "###  Install samba server  ###"
sudo yum install samba samba-client -y
sudo systemctl enable smb.service
echo "###  Add group and user  ###"
sudo mkdir ${Filesystem_to_share}
sudo groupadd ${GROUP}
sudo chgrp ${GROUP} $Filesystem_to_share 
sudo chmod 2770 ${Filesystem_to_share}
sudo useradd -M -s /usr/sbin/nologin -G ${GROUP} ${USER}
(echo "${PASSWD}"; echo "${PASSWD}") |sudo smbpasswd -s -a ${USER}
sudo smbpasswd -e ${USER}

cat << EOF |sudo tee -a $samba_config
[$share_name]
    path   =  ${Filesystem_to_share}
    browseable = no
    read only = no
    force create mode = 0660
    force directory mdoe = 2770
    valid users = $USER
EOF

sudo systemctl restart smb.service
echo "### Success ###"

