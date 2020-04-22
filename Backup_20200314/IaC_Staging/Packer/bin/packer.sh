#! /bin/bash

/opt/hashicorp/packer/bin/packer validate $1
/opt/hashicorp/packer/bin/packer build $1

