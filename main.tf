locals {
  name_base = lower("${var.project_name}-${var.participant}")
  tags_base = {
    Purpose = ""
  }
}

# ------------------
# --- S3 Buckets ---
# ------------------

module "s3_logs" {
  source              = "./modules/s3-bucket"
  bucket_name         = "${local.name_base}-logs"
  enable_versioning   = false
  encryption_type     = "SSE-S3"
  block_public_access = true
  tags                = merge(local.tags_base, { Purpose = "logs-bucket" })

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
  tags                = merge(local.tags_base, { Purpose = "landing-bucket" })

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
  tags                = merge(local.tags_base, { Purpose = "staging-bucket" })

  lifecyclePolicy = {
    enable                   = true
    transition_to_class_days = 60
    transition_storage_class = "INTELLIGENT_TIERING"
    expire_after_days        = 730
  }
}

# ------------------
# --- SQS Queues ---
# ------------------

module "sqs_landing" {
  source = "./modules/sqs-queue"
  name   = "${local.name_base}-landing"
  tags   = merge(local.tags_base, { Purpose = "landing-queue" })
}

module "sqs_splitter" {
  source = "./modules/sqs-queue"
  name   = "${local.name_base}-splitter"
  tags   = merge(local.tags_base, { Purpose = "splitter-queue" })
}

# ---------------
# --- Lambdas ---
# ---------------

module "lambda_extract" {
  source             = "./modules/lambda_sqs_consumer"
  name               = "${local.name_base}-extract"
  queue_arn          = module.sqs_landing.arn
  code_dir           = "${path.root}/lambda/extract"
  iam_admin_role_arn = var.iam_admin_role_arn

  env = {
    LANDING_BUCKET     = module.s3_landing.bucket_name
    SPLITTER_QUEUE_URL = module.sqs_splitter.url
    LOG_BUCKET         = module.s3_logs.bucket_name
  }

  tags = merge(local.tags_base, { Purpose = "extract-lambda" })
}

module "lambda_splitter" {
  source             = "./modules/lambda_sqs_consumer"
  name               = "${local.name_base}-splitter"
  queue_arn          = module.sqs_splitter.arn
  code_dir           = "${path.root}/lambda/splitter"
  iam_admin_role_arn = var.iam_admin_role_arn

  env = {
    STAGING_BUCKET = module.s3_staging.bucket_name
  }

  tags = merge(local.tags_base, { Purpose = "splitter-lambda" })
}

module "lambda_sfn_transform" {
  source             = "./modules/lambda_sfn_transform"
  name               = "${local.name_base}-sfn-transform"
  code_dir           = "${path.root}/lambda/transform"
  iam_admin_role_arn = var.iam_admin_role_arn

  env = {
    STAGING_BUCKET = module.s3_staging.bucket_name
  }

  tags = merge(local.tags_base, { Purpose = "sfn-transform-lambda" })
}

# ---------------------
# --- Step-Function ---
# ---------------------

module "sfn_transform" {
  source               = "./modules/step-function"
  name                 = "${local.name_base}-sfn-transform"
  iam_admin_role_arn   = var.iam_admin_role_arn
  transform_lambda_arn = module.lambda_sfn_transform.function_arn
  tags                 = merge(local.tags_base, { Purpose = "sfn-transform" })
}

