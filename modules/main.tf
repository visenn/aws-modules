resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "logging" {
    for_each = var.s3_access_logs_bucket_arn != "" ? [1] : []
    content {
      target_bucket = replace(var.s3_access_logs_bucket_arn, "/.*$", "")
      target_prefix = replace(var.s3_access_logs_bucket_arn, "^.*/", "")
    }
  }

  lifecycle_rule {
    id      = "standard_ia_rule"
    status  = "Enabled"
    enabled = var.lifecycle_rule != {} && var.lifecycle_rule.days_to_standard_ia > 0

    transition {
      days          = var.lifecycle_rule.days_to_standard_ia
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle_rule {
    id      = "glacier_rule"
    status  = "Enabled"
    enabled = var.lifecycle_rule != {} && var.lifecycle_rule.days_to_glacier > 0

    transition {
      days          = var.lifecycle_rule.days_to_glacier
      storage_class = "GLACIER"
    }
  }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_id
        sse_algorithm    = "aws:kms"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  bucket_acl {
    acl = "private"
  }

  uniform_bucket_level_access = true

  dynamic "acl" {
    for_each = var.cross_account_roles
    content {
      permission = var.cross_account_roles[acl.key].permissions
      grants = [{
        type        = "CanonicalUser"
        permissions = ["FULL_CONTROL"]
        id          = aws_iam_role.acl[acl.key].id
      }]
    }
  }


  dynamic "cloudtrail" {
    for_each = var.enable_cloudtrail_data_events ? [1] : []
    content {
      name = "s3-data-events"
    }
  }
}

resource "aws_iam_role" "acl" {
  for_each = var.cross_account_roles
  name     = "cross-account-access-role-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        AWS = var.cross_account_roles[each.key].role_arn
      }
    }]
  })
}
