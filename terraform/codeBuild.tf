resource "aws_codebuild_project" "react_image_compressor" {
  name = "react-image-compressor"
  description = "Build and deploy the React Image Compressor application"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = "true"
    environment_variable {
      name = "REACT_APP_API_URL"
      value = aws_ecr_repository.image-compressor.repository_url
    }

    dynamic "environment_variable" {
      for_each = var.env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type = "GITHUB"
    location = "https://github.com/luca-loiacono/react-image-compressor"
    buildspec = "buildspec.yml"
  }
}
