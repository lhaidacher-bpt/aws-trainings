resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "${var.name}-rule"
  description = "Start SFN on S3 ObjectCreated for ${var.source_bucket_name}/${var.prefix}"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : { "name" : [var.source_bucket_name] },
      "object" : { "key" : [{ "wildcard" : "${var.prefix}/*.json" }] }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "start_sfn" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "sfn-${var.name}"
  arn       = var.target_sfn_arn
  role_arn  = var.iam_admin_role_arn

  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
    }
    input_template = "{\"bucket\": <bucket>, \"key\": <key>}"
  }
}