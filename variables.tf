variable "aws_region" {
    type = string
    description = "The AWS region to create resources in"
    default = "us-east-1"
}

variable "bucket_name" {
  description = "Provide a unique name for the S3 bucket"
  type        = string
}