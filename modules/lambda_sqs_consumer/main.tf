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

# Assume Role
data "aws_iam_policy_document" "assume" {
  //TODO
}

resource "aws_iam_role" "execution" {
  //TODO
}

# Logs
data "aws_iam_policy_document" "logs" {
  //TODO
}

resource "aws_iam_role_policy" "logs" {
  //TODO
}

# SQS Policy: Read & Write
data "aws_iam_policy_document" "sqs" {
  //TODO
}

resource "aws_iam_role_policy" "sqs" {
  //TODO
}

# S3 Policy
data "aws_iam_policy_document" "s3" {
  //TODO
}

resource "aws_iam_role_policy" "s3" {
  //TODO
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

resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn                   = var.sqs_read_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.batch_window_seconds
  function_response_types            = ["ReportBatchItemFailures"]
}
