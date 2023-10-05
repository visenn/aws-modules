module "s3_bucket" {
  source = "./modules/s3-gold-module"

  bucket_name = "vis-s3-example-2201"  # Change to your desired bucket name
  versioning = true  # Set to true to enable versioning
  s3access = {
    #bucket = "arn:aws:s3:::aws-logs-612820001683-eu-west-1"
    bucket = "aws-logs-612820001683-eu-west-1"
    prefix = "vis-s3-example-2201/"  
  }
  object_lifecycle = {
    #ia_transition_days = 30  # Set to the desired number of days to move to Standard-IA
    glacier_transition_days = 3650     # Set to the desired number of days to move to Glacier
  }
  external_iam_roles = [
    {
      arn      = "arn:aws:iam::976042434071:role/AdmRole4Viscon"
      subfolder   = "example-folder1"
      permissions   = "readonly"
    },
    {
      arn      = "arn:aws:iam::121653596033:role/AdmRole4Viscon"
      subfolder   = "example-folder2"
      permissions   = "read_write"
    },
    {
      arn      = "arn:aws:iam::121653596033:user/acn"
      subfolder   = "acn"
      permissions   = "readonly"
    },
  ] 
  #kms_key_id = "arn:aws:kms:eu-west-1:612820001683:key/9de9445c-17d6-4a09-92d5-62610ad2dcaa"
  kms_key_id = "9de9445c-17d6-4a09-92d5-62610ad2dcaa"
}
