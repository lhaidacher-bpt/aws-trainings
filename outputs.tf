output "buckets" {
  value = {
    logs    = try(module.s3_logs.bucket_name, null)
    landing = try(module.s3_landing.bucket_name, null)
    staging = try(module.s3_staging.bucket_name, null)
  }
}
