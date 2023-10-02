resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "logging" {
    for_each = var.s3access_logs_bucket_arn != null ? [1] : []
    content {
      target_bucket = var.s3access_logs_bucket_arn
      target_prefix = "logs/"
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

  dynamic "acl" {
    for_each = var.cross_account_iam_roles
    content {
      permission = "read"
      grants = [{
        type        = "CanonicalUser"
        permissions = ["FULL_CONTROL"]
        id          = aws_iam_role.acl[each.key].id
      }]
    }
  }
}

resource "aws_iam_role" "acl" {
  for_each = toset(var.cross_account_iam_roles)
  name     = "cross-account-access-role-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        AWS = each.value
      }
    }]
  })
}
