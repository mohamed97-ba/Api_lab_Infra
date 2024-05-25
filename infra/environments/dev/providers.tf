terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.46.0"

    }
  }

}
provider "aws" {
  region = "eu-west-3"


  default_tags {
    tags = {
      Environment = var.environment
      Name        = "mohamed"
    }
  }
}


