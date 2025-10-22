output "buckets" {
  value = {
    logs    = try(module.s3_logs.bucket_name, null)
    landing = try(module.s3_landing.bucket_name, null)
    staging = try(module.s3_staging.bucket_name, null)
  }
}

output "queues" {
  value = {
    landing  = try(module.sqs_landing.name, null)
    splitter = try(module.sqs_splitter.name, null)
  }
}

output "lambdas" {
  value = {
    extract       = try(module.lambda_extract.function_name, null)
    splitter      = try(module.lambda_splitter.function_name, null)
    sfn_transform = try(module.lambda_sfn_transform.function_name, null)
  }
}

output "step_function" {
  value = try(module.sfn_transform.state_machine_name, null)
}

output "event_bridge_rule" {
  value = try(module.eventbridge_raw_to_sfn.rule_name, null)
}

output "app_flow" {
  value = try(module.appflow_s3_to_salesforce.flow_name, null)
}