variable "versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3access" {
  description = "S3 access logs configuration"
  type = object({
    bucket = string
    prefix = string
  })
  default = null
}

variable "object_lifecycle" {
  description = "Lifecycle configuration for transition to IA and Glacier"
  type = object({
    ia_transition_days     = number
    glacier_transition_days= number
  })
  default = null
}

variable "external_iam_roles" {
  description = "IAM roles from other AWS accounts and their permissions"
  type = list(object({
    arn         = string
    subfolder   = string
    permissions = string # "readonly" or "readwrite"
  }))
  default = []
}

variable "enable_data_events" {
  description = "Enable CloudTrail Data Events"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS Key ID for S3 bucket encryption"
  type        = string
}

variable "bucket_name" {
  description = "The name of bucket"
  type        = string
}
