locals {
  name_base = lower("${var.project_name}-${var.participant}")
  tags_base = {
    Purpose = ""
  }
}

module "s3_logs" {
  source              = "./modules/s3-bucket"
  bucket_name         = "${local.name_base}-logs"
  enable_versioning   = false
  encryption_type     = "SSE-S3"
  block_public_access = true
  tags                = merge(local.tags_base, { Purpose = "logs" })

  lifecyclePolicy = {
    enable                   = true
    transition_to_class_days = 30
    transition_storage_class = "GLACIER_IR"
    expire_after_days        = 365
  }
}


module "s3_landing" {
  source              = "./modules/s3-bucket"
  bucket_name         = "${local.name_base}-landing"
  enable_versioning   = true
  encryption_type     = "SSE-S3"
  block_public_access = true
  tags                = merge(local.tags_base, { Purpose = "landing" })

  lifecyclePolicy = {
    enable               = true
    expire_after_days    = 180
    abort_multipart_days = 7
  }
}

module "s3_staging" {
  source              = "./modules/s3-bucket"
  bucket_name         = "${local.name_base}-staging"
  enable_versioning   = true
  encryption_type     = "SSE-S3"
  block_public_access = true
  tags                = merge(local.tags_base, { Purpose = "staging" })

  lifecyclePolicy = {
    enable                   = true
    transition_to_class_days = 60
    transition_storage_class = "INTELLIGENT_TIERING"
    expire_after_days        = 730
  }

  #encryption_type     = "SSE-KMS"
  #kms_key_id          = aws_kms_key.staging.arn
}
