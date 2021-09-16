terraform {
  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-mastering-aws-vpc" 
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
  }
}
