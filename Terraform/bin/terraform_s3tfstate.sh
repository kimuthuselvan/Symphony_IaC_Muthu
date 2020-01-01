#! /bi/bash
export TERRAFORM_PATH=/awsops/opt/hashicorp/terraform/bin/
export TF_LOG=TRACE
export TF_LOG_PATH=${TERRAFORM_BASE}/logs/terraform.`date +'%Y%m%d%H%M%S'`.log
export TF_PLUGIN_CACHE_DIR="$TERRAFORM_BASE/.terraform.d/plugin-cache"

$TERRAFORM_PATH/terraform init
$TERRAFORM_PATH/terraform plan
$TERRAFORM_PATH/terraform apply
$TERRAFORM_PATH/terraform deploy
$TERRAFORM_PATH/terraform show

