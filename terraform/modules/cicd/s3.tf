resource "aws_s3_bucket" "codebuild-bucket" {
  #key =  "${var.file-name}"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
  #for_each loop not recognised by #checkov
  bucket = "${var.pipeline_deployment_bucket_name}-codebuild-deploymentdep12"

  tags = var.custom_tags
}

resource "aws_s3_bucket" "codepipeline-bucket" {
  #key =  "${var.file-name}"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
  #for_each loop not recognised by #checkov
  bucket = "${var.pipeline_deployment_bucket_name}-codepipeline-deploymentdep12"


  tags = var.custom_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_buckets" {
  for_each = local.buckets_to_lock
  bucket   = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "pipeline_buckets" {
  for_each = local.buckets_to_lock
  bucket   = each.value
  acl      = "private"
}

resource "aws_s3_bucket_versioning" "pipeline-buckets" {
  for_each = local.buckets_to_lock
  bucket   = each.value
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline-buckets" {
  for_each                = local.buckets_to_lock
  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "glue_scripts" {
  bucket = var.glue_scripts_bucket
}

resource "aws_s3_bucket_versioning" "versioning_glue_scripts_bucket" {
  bucket = aws_s3_bucket.glue_scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_object" "upload_glue_script" {
  depends_on = [aws_s3_bucket.glue_scripts]
  bucket     = aws_s3_bucket.glue_scripts.id
  key        = "Dev-DAT-5678_deployment.py"
  #key    =  file(${path.module}/Scripts/${var.file-name})
  source = "../../modules/cicd/glue_scripts/Dev-DAT-5678_deployment.py"
}

resource "aws_s3_bucket_object" "upload_cfn_template" {
  depends_on = [aws_s3_bucket.glue_scripts]
  bucket     = aws_s3_bucket.glue_scripts.id
  key        = "cfntemplates/cfn.zip"
  #key    =  file(${path.module}/Scripts/${var.file-name})
  source = "../../modules/cicd/templates/cfn.zip"
}
