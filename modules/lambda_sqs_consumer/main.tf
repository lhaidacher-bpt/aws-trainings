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

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "logs" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "logs" {
  name   = "${var.name}-lambda-logs"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"]
    resources = [var.sqs_read_arn]
  }

  dynamic "statement" {
    for_each = var.sqs_send_arn != null ? [1] : []
    content {
      actions   = ["sqs:SendMessage", "sqs:SendMessageBatch", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"]
      resources = [var.sqs_send_arn]
    }
  }
}

resource "aws_iam_role_policy" "sqs" {
  name   = "${var.name}-lambda-sqs"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "s3" {
  dynamic "statement" {
    for_each = length(var.s3_put_arns) > 0 ? [1] : []
    content {
      actions   = ["s3:PutObject", "s3:AbortMultipartUpload"]
      resources = var.s3_put_arns
    }
  }
}

resource "aws_iam_role_policy" "s3" {
  name   = "${var.name}-s3"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = aws_iam_role.execution.arn
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
