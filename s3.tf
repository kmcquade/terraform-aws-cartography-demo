module "s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=master"
  # If the cartography config is not empty, create the bucket to hold the config
  enabled = true
  //  enabled                  = var.cartography_config_rendered != "" ? true : false
  //  allowed_bucket_actions   = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
  versioning_enabled           = var.enable_bucket_versioning
  name                         = var.name
  namespace                    = var.namespace
  stage                        = var.stage
  sse_algorithm                = "aws:kms"
  force_destroy                = var.force_destroy
  allow_encrypted_uploads_only = true
  kms_master_key_arn           = aws_kms_key.s3_key.arn
  //  kms_master_key_arn = var.cartography_config_rendered != "" ? aws_kms_key.s3_key.arn : ""
}

resource "aws_kms_key" "s3_key" {
  //  count                   = var.cartography_config_rendered != "" ? 1 : 0
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = ""
  tags                    = module.bucket_kms_key_label.tags
  description             = "KMS key for S3"
}

resource "aws_kms_alias" "default" {
  //  count = var.cartography_config_rendered != "" ? 1 : 0
  name          = "alias/${var.kms_key_alias}-s3"
  target_key_id = join("", aws_kms_key.s3_key.*.id)
}

resource "aws_s3_bucket_object" "cartography_config" {
  # If the cartography config is not empty, create the bucket object to hold the config
  //  count = var.cartography_config_rendered != "" ? 1 : 0
  bucket = module.s3_bucket.bucket_id
  key    = "cartography/aws_config.ini"
  # If the cartography config variable is not empty, use the variable contents - otherwise use the template bundled here.
  content = var.cartography_config_rendered != "" ? var.cartography_config_rendered : file("${path.module}/templates/aws_config_default.ini")
}
