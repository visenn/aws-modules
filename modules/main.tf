resource "aws_s3_bucket" "bucket" {
  bucket = "my-tf-test-bucket"
  acl    = "private"

  versioning {
    enabled = var.versioning
  }

  logging {
    target_bucket = var.s3access != null ? var.s3access.bucket : null
    target_prefix = var.s3access != null ? var.s3access.prefix : null
  }

  lifecycle_rule {
    id      = "transition-rule"
    status  = "Enabled"

    transition {
      days          = var.lifecycle != null ? var.lifecycle.ia_transition_days : 0
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.lifecycle != null ? var.lifecycle.glacier_transition_days : 0
      storage_class = "GLACIER"
    }
  }

  # Adding bucket policy to grant IAM roles access
  dynamic "policy" {
    for_each = var.external_iam_roles
    content {
      arn = policy.value.arn
      actions = policy.value.permissions == "readonly" ? ["s3:GetObject"] : ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = ["${aws_s3_bucket.bucket.arn}/${policy.value.subfolder}/*"]
    }
  }

  # Server-side encryption using the provided KMS key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Block public access
  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_cloudtrail" "this" {
  count           = var.enable_data_events ? 1 : 0
  name            = "my-cloudtrail"
  s3_bucket_name  = aws_s3_bucket.bucket.bucket

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}
