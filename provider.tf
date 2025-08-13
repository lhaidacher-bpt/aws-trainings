terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  skip_metadata_api_check     = true

  #export AWS_ACCESS_KEY_ID=dummy
  #export AWS_SECRET_ACCESS_KEY=dummy
  #export AWS_DEFAULT_REGION=eu-central-1

  default_tags {
    tags = local.default_tags
  }
}

locals {
  default_tags = {
    "Project"            = var.project_name
    "Owner"              = var.participant
    "ManagedByTerraform" = "true"
  }
}
