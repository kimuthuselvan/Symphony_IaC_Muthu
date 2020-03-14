variable "workspace_to_environment_map" {
  type = "map"
  default = {
    dev = "dev"
    uat = "uat"
    prd = "prd"
  }
}

variable "environment_to_size_map" {
  type = "map"
  default = {
    dev = "medium"
    ust = "medium"
    prd = "medium"
  }
}


