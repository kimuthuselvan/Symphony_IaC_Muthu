provider "aws" {
  region = var.region_name
  profile = "default"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_security"
  profile = "eh_adv_aws_security_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_main"
  profile = "eh_adv_aws_main_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_vdi"
  profile = "eh_adv_aws_vdi_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_ahs"
  profile = "eh_adv_aws_ahs_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_alcc"
  profile = "eh_adv_aws_alcc_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_Adv_aws_kansas"
  profile = "eh_Adv_aws_kansas_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_sentara"
  profile = "eh_adv_aws_sentara_build"
}

provider "aws" {
  region  = var.region_name
  alias   = "eh_adv_aws_nebraska"
  profile = "eh_adv_aws_nebraska_build"
}
