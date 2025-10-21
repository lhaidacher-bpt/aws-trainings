variable "name" {
  description = "Flow-Name"
  type        = string
}

variable "iam_admin_role_arn" {
  description = "IAM Role ARN für Admin"
  type        = string
}

variable "connector_profile_name" {
  description = "Name des bestehenden Salesforce Connector Profiles"
  type        = string
}

variable "bucket_name" {
  description = "S3 Staging Bucket"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix im Staging Bucket"
  type        = string
}

variable "salesforce_object" {
  description = "Ziel-Objekt in Salesforce"
  type        = string
}

variable "schedule_expression" {
  description = "Trigger-Planung"
  type        = string
  default     = "rate(1 minutes)"
}

variable "dest_field_id" {
  type = string
}

variable "dest_field_vorname" {
  type = string
}

variable "dest_field_nachname" {
  type = string
}

variable "tags" {
  description = "Zusätzliche Tags"
  type        = map(string)
  default     = {}
}