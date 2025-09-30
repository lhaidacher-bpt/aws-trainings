terraform {
  required_providers {
    aws     = { source = "hashicorp/aws", version = ">= 5.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.2.0" }
  }
}

locals { zip_out = "${path.module}/build/${var.name}.zip" }

data "archive_file" "zip" {
  // TODO Implementierung - Tipp: siehe existierenden Terraform-Lambda-Code
}

resource "aws_lambda_function" "this" {
  // TODO Implementierung - Tipp: siehe existierenden Terraform-Lambda-Code
}
