terraform {
  backend "s3" {
    bucket = "terraform-remote-state-pro-lab"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
