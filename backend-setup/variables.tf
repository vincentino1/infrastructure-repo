variable "bucket_name" {
  type        = string
  description = "S3 bucket name for storing backend state"
  default     = "terraform-kubeadm-state-s3-bucket"
  
}