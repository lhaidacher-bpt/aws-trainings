variable "project_name" {
  description = "Project name"
  type        = string
  default     = "fosil-training"
}

variable "participant" {
  description = "Name of the training attendee"
  type        = string
  # Kein default, soll im terraform.tfvars definiert werden
}

variable "iam_admin_role_arn" {
  description = "IAM Admin Role ARN"
  type        = string
  # Kein default, soll im terraform.tfvars definiert werden
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}
