variable "bucket_name" {
  description = "The name of the S3 bucket to create."
}

variable "versioning_enabled" {
  description = "Set to true to enable versioning."
  default     = false
}

variable "s3access_logs_bucket_arn" {
  description = "Optional S3 access logs bucket ARN."
  default     = null
}

variable "lifecycle_rule" {
  description = "Optional lifecycle policy configuration."
  default     = {}
}


variable "cross_account_roles" {
  description = "Map of IAM roles, folder paths, and permissions."
  type        = map(object({
    role_arn    = string
    folder_path = string
    permissions = string
  }))
  default     = {}
}
