resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  
  tags = var.tags
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_configuration" {
  bucket = aws_s3_bucket.bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_key.for_gold.id
      sse_algorithm     = "aws:kms"
    }
  }
}

/* resource "aws_s3_bucket_acl" "bucket_acl" {
 bucket = aws_s3_bucket.bucket.id
 acl    = "private"
} */

/* resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.bucket-one-two.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
} */

/* Since April 2023 AWS activates by default "BucketOwnerEnforced" ownership in the bucket
   which disables ACL. This is why it is not possible to define ACL resource.
   If the object ownership would be defined to "ObjectWriter" then ACL can be defined and for example set as "private" */

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count  = var.s3access != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  
  target_bucket = var.s3access.bucket
  target_prefix = var.s3access.prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = var.object_lifecycle != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id      = "transition-rule"
    status = "Enabled"

    dynamic "transition" {
      for_each = var.object_lifecycle.ia_transition_days != null ? [var.object_lifecycle.ia_transition_days] : []
      content {
        days          = transition.value
        storage_class = "STANDARD_IA"
      }
    }

    dynamic "transition" {
      for_each = var.object_lifecycle.glacier_transition_days != null ? [var.object_lifecycle.glacier_transition_days] : []
      content {
        days          = transition.value
        storage_class = "GLACIER"
      }
    }
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
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  # Construct the bucket policy dynamically based on the provided IAM roles and permissions
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [for role in var.external_iam_roles : {
      Action   = role.permissions == "readonly" ? ["s3:GetObject"] : ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.bucket.arn}/${role.subfolder}/*",
      Principal = {
        AWS = role.arn
      }
    }]
  })
}

data "aws_kms_key" "for_gold" {
  key_id = var.kms_key_id
}


resource "aws_kms_grant" "kms_grant" {
  for_each          = { for role in var.external_iam_roles : role.arn => role }
  name              = "KMSGrant-${each.value.arn}"
  key_id            = data.aws_kms_key.for_gold.id
  grantee_principal = each.key  # Each IAM Role ARN
  
  operations = [
    "Encrypt",
    "Decrypt",
    "ReEncryptFrom",
    "ReEncryptTo",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "DescribeKey"
  ]
  
#  constraints {
#    encryption_context_subset = {
#      "s3:x-amz-server-side-encryption" = "aws:kms"
#    }
#  }
}
