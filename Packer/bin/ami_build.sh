#! /bin/bash
export PATH=$PATH:/opt/hashicorp/packer/bin

/opt/hashicorp/packer/bin/packer validate $1
/opt/hashicorp/packer/bin/packer build $1


