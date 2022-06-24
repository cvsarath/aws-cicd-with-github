locals {
  buckets_to_lock = {
    codepipeline = aws_s3_bucket.codepipeline-bucket.id
    codebuild    = aws_s3_bucket.codebuild-bucket.id
  }
  cfn_deploy_role_name = "cfn-deploy-${var.git_repository_name}"
  cfn_deploy_policy_name = "cfn-deploy-policy-${var.git_repository_name}"
  codepipeline_role_name   = "codepipeline-${var.git_repository_name}"
  codepipeline_policy_name = "codepipeline-policy-${var.git_repository_name}"
  region                   = var.region != "" ? var.region : data.aws_region.current.name
  account_id               = var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id
}
