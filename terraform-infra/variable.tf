variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "ca-central-1"
  
}
variable "cluster_name" {
    description = "The name of the Kubernetes cluster"
    type        = string
    default     = "my-k8s-cluster"
  
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

  
variable "public_subnets" {
    description = "List of public subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "private_subnets" {
    description = "List of private subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod."
  }
}

variable "nat_gateway_tags" {
  type = map(string)
  default = {
    Name        = "nat-gw"
  }
}

variable "igw_tags" {
  description = "Tags to apply to Internet Gateways"
  type        = map(string)
  default     = {
    Name        = "igw"
  }
}

variable "admin_ip" {
  description = "Admin IP address allowed to access Jenkins"
  type        = string
  default     = "75.159.12.178/32"
}


variable "tags" {
  description = "Standard resource tags"
  type        = map(string)
  default     = {
    Project     = "CI/CD-Kubernetes-Deployment"
    Owner       = "DevOpsTeam"
  }
}

# variable "instance_type" {
#   type        = string
#   default     = "t3.medium"
#   description = "EC2 instance type for worker nodes"
# }

variable "jenkins_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type for Jenkins server"
}

variable "nexus_instance_type" {
  type        = string
  default     = "t3.large"
  description = "EC2 instance type for Nexus server"
  
}

variable "proxy_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type for Nginx Proxy server"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t3.nano"
  description = "EC2 instance type for bastion host"
}

# variable "db_instance_type" {
#   type        = string
#   default     = "t3.small"
#   description = "EC2 instance type for database server"
  
# }

# variable "worker_names" {
#   type        = list(string)
#   default     = ["k8s-worker-1", "k8s-worker-2", "k8s-worker-3"]
#   description = "List of worker node names"
# }

# variable "master_names" {
#   type        = list(string)
#   default     = ["k8s-master-1"]
#   description = "List of master node names"
# }

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name"
  default     = "my-project-key"
}

# variable "master_volume_size" {
#   type        = number
#   default     = 50
#   description = "Root volume size in GB"
# }

# variable "worker_volume_size" {
#   type        = number
#   default     = 50
#   description = "Root volume size in GB"
# }

variable "jenkins_volume_size" {
  type        = number
  default     = 30
  description = "Root volume size in GB"
  
}

variable "nexus_volume_size" {
  type        = number
  default     = 50
  description = "Root volume size in GB"
}

variable "proxy_volume_size" {
    type        = number
    default     = 10
    description = "Root volume size in GB"
}

# variable "db_volume_size" {
#   type        = number
#   description = "Root volume size in GB"
#   default     = 50
# }

variable "bastion_volume_size" {
    type        = number
    default     = 8
    description = "Root volume size in GB"
}
    