resource "aws_iam_role" "codebuild" {
  name = "react-image-compressor-codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

data "local_file" "policy" {
  filename = "policy/policy.json"
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name
  policy = replace(replace(replace(data.local_file.policy.content, "ACCOUNT_ID", var.account_id), "CODEBUILD_NAME", var.codebuild_name), "AWS_REGION", var.aws_region)
}
