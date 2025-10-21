output "rule_arn" { value = aws_cloudwatch_event_rule.s3_object_created.arn }
output "target_id" { value = aws_cloudwatch_event_target.start_sfn.target_id }