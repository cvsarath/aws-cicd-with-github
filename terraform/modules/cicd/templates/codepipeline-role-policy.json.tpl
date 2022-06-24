{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:Get*",
        "s3:Put*",
        "s3:List*"
      ],
      "Resource": [
        "${codepipeline_bucket_arn}",
        "${codepipeline_bucket_arn}/*",
        "arn:aws:s3:::glue-scripts-360",
        "arn:aws:s3:::glue-scripts-360/*"
      ]
    },
    
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "cloudformation:*",
        "iam:PassRole",
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}