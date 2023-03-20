resource "aws_ecr_repository" "image-compressor" {
  name = "image-compressor"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "image-compressor_policy" {
  repository = aws_ecr_repository.image-compressor.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        selection = {
          tagStatus = "untagged"
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

