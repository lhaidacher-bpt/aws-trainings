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

  # Nur für lokale Tests ohne AWS CLI Integration
  #skip_credentials_validation = true
  #skip_requesting_account_id  = true
  #skip_region_validation      = true
  #skip_metadata_api_check     = true

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
