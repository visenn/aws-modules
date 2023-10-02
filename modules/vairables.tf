variable "bucket_name" {
  description = "The name of the S3 bucket."
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket."
  default     = false
}

variable "s3_access_logs_bucket_arn" {
  description = "Object specifying the ARN of the S3 bucket for access logs and the folder path."
  type = object({
    bucket_arn   = string
    folder_path  = string
  })
  default = {
    bucket_arn  = ""
    folder_path = ""
  }
}

variable "lifecycle_transition_days_standard_ia" {
  description = "Number of days to transition objects to Standard-IA storage class."
  default     = -1
}

variable "lifecycle_transition_days_glacier" {
  description = "Number of days to transition objects to Glacier storage class."
  default     = -1
}

variable "cross_account_roles" {
  description = "Map of IAM roles and their access to specific folders in the bucket."
  type        = map(object({
    role_arn      = string
    folder_path   = string
    permissions   = list(string)
    access_types  = list(string)
  }))
  default = {}
}

variable "kms_key_id" {
  description = "The ID of the KMS key to use for bucket encryption."
}

variable "cloudtrail_data_events_enabled" {
  description = "Enable AWS CloudTrail Data Events for the S3 bucket."
  default     = false
}
