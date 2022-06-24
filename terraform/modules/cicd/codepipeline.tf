resource "aws_codecommit_repository" "code_repo" {
  # depends_on = [
  #   aws_s3_bucket.glue_scripts,
  #   aws_s3_bucket_object.upload_glue_script
  # ]
  repository_name = var.git_repository_name
  description     = "Code Repository"

  tags = var.custom_tags
}


resource "aws_codepipeline" "codepipeline" {
    # depends_on = [
  #   aws_s3_bucket.glue_scripts,
  #   aws_s3_bucket_object.upload_glue_script,
  #   aws_s3_bucket_object.upload_cfn_template
  # ]
  for_each = toset(var.branches)
  name     = "${var.git_repository_name}-${each.value}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline-bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source-${var.git_repository_name}"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        RepositoryName = var.git_repository_name
        BranchName     = each.value
      }
    }
  }

    stage {
    name = "Build"

    action {
      name             = "Build-${aws_codebuild_project.codebuild_deployment["build"].name}"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_deployment["build"].name
        EnvironmentVariables = jsonencode([{
          name  = "ENVIRONMENT"
          value = each.value
          },
          {
            name  = "PROJECT_NAME"
            value = var.account_type
        }])
      }
    }
  }
  # stage {
  #      name = "Source"
  #     action {
  #     name             = "TfTemplate"
  #     category         = "Source"
  #     owner            = "AWS"
  #     provider         = "S3"
  #     version          = "1"
  #     output_artifacts = ["TfTemplate"]

  #     configuration = {
  #       S3Bucket = "glue-scripts-360"
  #       S3ObjectKey = "cfntemplates/cfn.zip"
  #       PollForSourceChanges = false
  #     }
  #   }
  # }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        RoleArn        = aws_iam_role.cfn_deploy_role.arn
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        StackName      = "MyStack1"
        TemplatePath   = "build_output::cfn.yaml"

      }
    }
  }
  tags = var.custom_tags
}
