terraform {
  required_providers {
    aws     = { source = "hashicorp/aws", version = ">= 5.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.2.0" }
  }
}

locals { zip_out = "${path.module}/build/${var.name}.zip" }

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.code_dir
  output_path = local.zip_out
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = var.iam_admin_role_arn
  runtime          = var.runtime
  handler          = "index.handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  architectures    = var.architectures
  timeout          = 10
  environment { variables = var.env }
  tags = var.tags
}