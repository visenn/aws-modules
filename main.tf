module "s3_bucket" {
  source = "./modules/"

  bucket_name = "vis-s3-example-2200"
  kms_key_id = "arn:aws:kms:eu-west-1:612820001683:key/44a3332f-8b09-451d-a690-0ac477359a69"
  
  cross_account_roles = {
    role1 = {
      role_arn      = "arn:aws:iam::976042434071:role/AdmRole4Viscon"
      folder_path   = "/folder1"
      permissions   = ["s3:GetObject"]
      access_types  = ["Allow"]
    },
    role2 = {
      role_arn      = "arn:aws:iam::121653596033:role/AdmRole4Viscon"
      folder_path   = "/folder2"
      permissions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      access_types  = ["Allow"]
    }
  }  
  
  s3_access_logs_bucket_arn = {
    bucket_arn   = "arn:aws:s3:::aws-logs-612820001683-eu-west-1"
    folder_path  = "vis-s3-example-2200/"
  }
}
