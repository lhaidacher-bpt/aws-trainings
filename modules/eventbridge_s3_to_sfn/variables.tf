variable "name" {
  description = "Kurzname für Rule/Role/Target"
  type        = string
}
variable "iam_admin_role_arn" {
  description = "IAM Role ARN für Admin"
  type        = string
}

variable "target_sfn_arn" {
  description = "ARN der Step Functions State Machine, die gestartet werden soll"
  type        = string
}

variable "source_bucket_name" {
  description = "Name des S3 Staging Buckets"
  type        = string
}

variable "prefix" {
  description = "S3-Key-Prefix, der Events auslöst"
  type        = string
}

variable "tags" {
  description = "Zusätzliche Tags; werden mit Provider default_tags gemerged"
  type        = map(string)
  default     = {}
}
