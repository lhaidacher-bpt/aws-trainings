output "buckets" {
  value = {
    logs = try(module.s3_logs.bucket_name, null)
    landing = try(module.s3_landing.bucket_name, null)
    staging = try(module.s3_staging.bucket_name, null)
  }
}

output "queues" {
  value = {
    landing = try(module.sqs_landing.name, null)
    splitter = try(module.sqs_splitter.name, null)
  }
}

output "lambdas" {
  value = {
    extract = try(module.lambda_extract.function_name, null)
    splitter = try(module.lambda_splitter.function_name, null)
  }
}
