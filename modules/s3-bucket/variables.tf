variable "bucket_name" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "encryption_type" {
  type    = string
  default = "SSE-S3"
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "block_public_access" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "lifecyclePolicy" {
  type = object({
    enable                   = bool
    transition_to_class_days = optional(number)
    transition_storage_class = optional(string)
    expire_after_days        = optional(number)
    abort_multipart_days     = optional(number)
  })
  default = { enable = false }
}
