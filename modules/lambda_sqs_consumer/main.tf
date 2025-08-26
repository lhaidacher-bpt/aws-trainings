locals { zip_out = "${path.module}/build/${var.name}.zip" }

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "inline" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [var.queue_arn]
  }

  dynamic "statement" {
    for_each = var.s3_put_object_arns
    content {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${statement.value}/*"]
    }
  }

  dynamic "statement" {
    for_each = var.sqs_send_arns
    content {
      effect    = "Allow"
      actions   = ["sqs:SendMessage", "sqs:SendMessageBatch"]
      resources = [statement.value]
    }
  }
}

resource "aws_iam_policy" "inline" {
  name   = "${var.name}-inline"
  policy = data.aws_iam_policy_document.inline.json
}

resource "aws_iam_role_policy_attachment" "inline_attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.inline.arn
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.code_dir
  output_path = local.zip_out
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = aws_iam_role.this.arn
  runtime          = var.runtime
  handler          = "index.handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  architectures    = var.architectures
  environment { variables = var.env }
  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn                   = var.queue_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.batch_window_seconds
  function_response_types            = ["ReportBatchItemFailures"]
}
