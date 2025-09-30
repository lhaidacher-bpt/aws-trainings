variable "name" {
  description = "Step-Function Name"
  type        = string
}

variable "iam_admin_role_arn" {
  description = "IAM Role ARN für Admin"
  type        = string
}

variable "transform_lambda_arn" {
  description = "Lambda ARN für Transformierung"
  type        = string
}

variable "tags" {
  description = "Zusätzliche Tags; werden mit Provider default_tags gemerged"
  type        = map(string)
  default     = {}
}