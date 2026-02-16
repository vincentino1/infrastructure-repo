terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

backend "s3" {
    bucket        = "terraform-kubeadm-state-s3-bucket"
    key           = "project/terraform.tfstate"
    region        = "ca-central-1"
    encrypt       = true
    use_lockfile = true # enables native S3 locking (no DynamoDB table needed)
  }
}

provider "aws" {
  region = var.aws_region
  
}
