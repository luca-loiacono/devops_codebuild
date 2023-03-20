variable "aws_region" {
  description = "AWS Region for this infrastructure"
  type        = string
  default     = "xx-xxx-x"
}

variable "env_vars" {
  default = {
    AWS_ACCESS_KEY = "xxxxxxxxxxxx"
    AWS_SECRET_ACCESS_KEY = "xxxxxxxxx"
    ECR_REPOSITORY = "xxxxxxxxxxxxx"
    AWS_REGION = "xx-xxx-x"
  }
} 

variable "account_id" {
  description = "AWS Account ID"
  type = string
  default = "xxxxxxxxxxxxx"
}

variable "codebuild_name" {
  description = "Codebuild project name"
  type = string
  default = "react-image-compressor"
}
