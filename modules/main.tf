resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = "private" # Block public access

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = var.versioning_enabled
  }

  logging {
    target_bucket = var.s3_access_logs_bucket_arn.bucket_arn
    target_prefix = var.s3_access_logs_bucket_arn.folder_path != "" ? var.s3_access_logs_bucket_arn.folder_path : "access-logs/"
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_transition_days_standard_ia >= 0 || var.lifecycle_transition_days_glacier >= 0 ? [true] : []
    content {
      id      = "example-lifecycle-rule"
      status  = "Enabled"

      transition {
        days          = var.lifecycle_transition_days_standard_ia
        storage_class = "STANDARD_IA"
      }

      transition {
        days          = var.lifecycle_transition_days_glacier
        storage_class = "GLACIER"
      }
    }
  }

  dynamic "grant" {
    for_each = var.cross_account_roles
    content {
      type        = "Principal"
      actions     = var.cross_account_roles[grant.key].permissions
      resources   = [aws_s3_bucket.s3_bucket.arn + var.cross_account_roles[grant.key].folder_path + "/*"]
      permissions = var.cross_account_roles[grant.key].access_types

      conditions {
        test     = "StringEquals"
        values   = [var.cross_account_roles[grant.key].role_arn]
        variable = "aws:userid"
      }
    }
  }

  # Enable uniform bucket-level access control
  bucket_level_access {
    enforce = true
  }

  # Enable CloudTrail Data Events
  dynamic "cloudtrail" {
    for_each = var.cloudtrail_data_events_enabled ? [true] : []
    content {
      event_name = "s3.amazonaws.com"
      include_management_events = true
      send_to_cloudtrail = true
    }
  }
}
