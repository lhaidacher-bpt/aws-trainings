resource "aws_sfn_state_machine" "this" {
  name       = var.name
  role_arn   = var.iam_admin_role_arn
  type       = "STANDARD"
  definition = <<EOF
{
  "Comment": "Transformierung der Rohevents (read->map->store->delete)",
  "StartAt": "TransformEvent",
  "States": {
    "TransformEvent": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "FunctionName": "${var.transform_lambda_arn}",
        "Payload.$": "$"
      },
      "Next": "WriteTransformed"
    },
    "WriteTransformed": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:s3:putObject",
      "Parameters": {
        "Bucket.$": "$.bucket",
        "Key.$": "States.Format('transformed/id={}/{}.json', $.transformedId, $.millis)",
        "Body.$": "$.event",
        "ContentType": "application/json"
      },
      "ResultPath": "$.putResult",
      "Next": "DeleteRaw"
    },
    "DeleteRaw": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:s3:deleteObject",
      "Parameters": {
        "Bucket.$": "$.bucket",
        "Key.$": "$.rawId"
      },
      "End": true
    }
  }
}
EOF

  tags = var.tags
}
