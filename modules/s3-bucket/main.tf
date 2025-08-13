resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_type == "SSE-KMS" ? "aws:kms" : "AES256"
      #kms_master_key_id = var.encryption_type == "SSE-KMS" ? var.kms_key_id : null
    }
    #bucket_key_enabled = var.encryption_type == "SSE-KMS" ? true : null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.lifecyclePolicy.enable ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "default"
    status = "Enabled"

    filter {}

    dynamic "transition" {
      for_each = var.lifecyclePolicy.transition_to_class_days != null && var.lifecyclePolicy.transition_storage_class != null ? [1] : []
      content {
        days          = var.lifecyclePolicy.transition_to_class_days
        storage_class = var.lifecyclePolicy.transition_storage_class
      }
    }

    dynamic "expiration" {
      for_each = var.lifecyclePolicy.expire_after_days != null ? [1] : []
      content {
        days = var.lifecyclePolicy.expire_after_days
      }
    }

    dynamic "abort_incomplete_multipart_upload" {
      for_each = var.lifecyclePolicy.abort_multipart_days != null ? [1] : []
      content {
        days_after_initiation = var.lifecyclePolicy.abort_multipart_days
      }
    }
  }
}
