terraform {
  backend "s3" {
    bucket  = "terraform-remote-state-med"
    key     = "tf-serverless-state"
    region  = "eu-west-3"
    encrypt = true
  }
}