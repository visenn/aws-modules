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

variable "cross_account_iam_roles" {
  description = "Optional list of IAM roles from other AWS accounts to grant access."
  type        = list(string)
  default     = []
}
