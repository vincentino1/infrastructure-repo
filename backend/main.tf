
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "ca-central-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-kubeadm-state-s3-bucket"
  force_destroy = true #AWS will allow the bucket to be destroyed even if it contains files


  lifecycle {
    prevent_destroy = false #Terraform will allow the bucket to be destroyed
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}