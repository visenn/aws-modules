module "s3_bucket" {
  source = "./modules/"

  bucket_name = "vis-s3-example-2200"  # Change to your desired bucket name
  versioning_enabled = true  # Set to true to enable versioning
  s3access_logs_bucket_arn = "arn:aws:s3:::aws-logs-612820001683-eu-west-1/vis-s3-example-2200"  # Provide the S3 access logs bucket ARN if needed
  lifecycle_rule = {
    days_to_standard_ia = 30  # Set to the desired number of days to move to Standard-IA
    days_to_glacier = 60     # Set to the desired number of days to move to Glacier
  }
  cross_account_roles = {
    role1 = {
      role_arn      = "arn:aws:iam::976042434071:role/AdmRole4Viscon"
      folder_path   = "example-folder1"
      permissions   = "read"
    },
    role2 = {
      role_arn      = "arn:aws:iam::121653596033:role/AdmRole4Viscon"
      folder_path   = "example-folder2"
      permissions   = "read_write"
    },
  } 
}
