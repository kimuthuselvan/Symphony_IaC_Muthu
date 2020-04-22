variable "region_name" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "cidr_ip_1" {}
variable "cidr_ip_2" {}
variable "cidr_ip_3" {}
variable "cidr_ip_4" {}
variable "name_prefix" {}
variable "tag_name_prefix" {}
variable "project" {}
variable "environment" {}
variable "client" {}
variable "zone" {}
variable "server" {}
#variable "ca_cert_identifier" {}

variable "timeouts" {
  type = map(string)
  default = {
    create = "80m"
    update = "80m"
    delete = "80m"
  }
}

