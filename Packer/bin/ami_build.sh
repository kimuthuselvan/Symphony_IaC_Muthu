#! /bin/bash
#export PATH=/opt/hashicorp/packer/bin:$PATH
export AWS_PROFILE=eh_adv_aws_main_build

aws2 ec2 describe-images \
    --owners 'aws-marketplace' \
    --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' \
    --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' \
    --output 'text'


#/opt/hashicorp/packer/bin/packer validate $1
#/opt/hashicorp/packer/bin/packer build $1


