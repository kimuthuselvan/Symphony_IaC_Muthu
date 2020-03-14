variable "region_name" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "cidr_ip_1" {}
variable "cidr_ip_2" {}
variable "cidr_ip_3" {}
variable "cidr_ip_4" {}

variable "timeouts" {
  type = map(string)
  default = {
    create = "80m"
    update = "80m"
    delete = "80m"
  }
}

