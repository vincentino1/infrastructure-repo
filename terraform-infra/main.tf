module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = var.cluster_name
  cidr = var.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets


  public_subnet_tags = {
    Name = "${var.environment}-k8s-public-subnet"
    Tier = "public"
  }

  private_subnet_tags = {
    Name = "${var.environment}-k8s-private-subnet"
    Tier = "private"
  }

  private_route_table_tags = {
    Name = "${var.environment}-k8s-private-rt"
  }

  public_route_table_tags = {
    Name = "${var.environment}-k8s-public-rt"
  }

  nat_gateway_tags = var.nat_gateway_tags
  igw_tags         = var.igw_tags

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
  Name = "${var.environment}-k8s-vpc"
})

}

################### APPLICATION LOAD BALANCER ###################################
############################# ALB Module #########################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.0"

  name     = "${var.environment}-public-alb"
  internal = false
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.public_subnets
  enable_deletion_protection = false

  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP access to ALB"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      # fixed_response = {
      #   status_code  = "404"
      #   content_type = "text/plain"
      #   message_body = "Not Found"
      # }
      forward = {
        target_group_key = "nexus"
      }

      rules = {
        nexus = {
          priority = 20
          actions = [
            {
              forward = {
                target_group_key = "nexus"  
              }                         
            }
          ]

          conditions = [
            {
              path_pattern = {
                values = ["/nexus*", "/repository*"]
              }
            }
          ]
        }

        jenkins = {
          priority = 10
          actions = [
            {
              forward = {
                target_group_key = "jenkins"
              }                          
            }
          ]
          conditions = [
            {
              path_pattern = {
                values = ["/jenkins*"]
              }
            }
          ]
        }
      }
    }
  }
  target_groups = {
    nexus = {
      name_prefix = "nex"
      port        = 8081
      protocol    = "HTTP"
      target_type = "instance"
      target_id        = module.nexus-server.id
      health_check = {
        path                = "/nexus/"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
    jenkins = {
      name_prefix = "jenks"
      port        = 8080
      protocol    = "HTTP"
      target_type = "instance"
      target_id        = module.jenkins-server.id
      health_check = {
        path                = "/jenkins/login"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-alb"
  })
}


################ Security Group Module #########################################

# ---------------------- MASTER SG ----------------------
# module "k8s_master_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.3"

#   name        = "${var.environment}-k8s-master-sg"
#   description = "Security group for Kubernetes control plane"
#   vpc_id      = module.vpc.vpc_id

 
#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 6443
#       to_port                  = 6443
#       protocol                 = "tcp"
#       description              = "Kubernetes API from workers"
#       source_security_group_id = module.k8s_worker_sg.security_group_id
#     },

#     {
#       from_port                = 6443
#       to_port                  = 6443
#       protocol                 = "tcp"
#       description              = "Kubernetes API from bastion"
#       source_security_group_id = module.bastion_sg.security_group_id
#     },

#     {
#       from_port                = 2379
#       to_port                  = 2380
#       protocol                 = "tcp"
#       description              = "etcd peer communication"
#       source_security_group_id = module.k8s_master_sg.security_group_id
#     },
#     {
#       from_port                = 10250
#       to_port                  = 10250
#       protocol                 = "tcp"
#       description              = "Kubelet API"
#       source_security_group_id = module.k8s_master_sg.security_group_id
#     },
#     {
#       from_port                = 22
#       to_port                  = 22
#       protocol                 = "tcp"
#       description              = "SSH from bastion"
#       source_security_group_id = module.bastion_sg.security_group_id
#     }
#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "all-all"
#       description = "Internal VPC traffic only"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   tags = merge(var.tags, {
#     Name = "${var.environment}-k8s-control-plane-sg"
#   })
# }

# # ---------------------- WORKER SG ----------------------
# module "k8s_worker_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.3"

#   name        = "${var.environment}-k8s-worker-sg"
#   description = "Security group for Kubernetes worker nodes"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 10250
#       to_port                  = 10250
#       protocol                 = "tcp"
#       description              = "Kubelet API from masters"
#       source_security_group_id = module.k8s_master_sg.security_group_id
#     },

#     {
#     from_port                = 22
#     to_port                  = 22
#     protocol                 = "tcp"
#     description              = "SSH from bastion"
#     source_security_group_id = module.bastion_sg.security_group_id
#     }

#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 30000
#       to_port     = 32767
#       protocol    = "tcp"
#       description = "NodePort services from vpc"
#       cidr_blocks = var.vpc_cidr
#     }
#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "all-all"
#       description = "Internal VPC traffic only"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   tags = merge(var.tags, {
#     Name = "${var.environment}-k8s-worker-sg"
#   })
# }

# # ---------------------- Nexus-sg ----------------------
module "nexus_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.environment}-nexus-sg"
  description = "Security group for Nexus server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Docker Registry"
      cidr_blocks = var.vpc_cidr
    }
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 8081
      to_port                  = 8081
      protocol                 = "tcp"
      source_security_group_id = module.alb.security_group_id
      description              = "Nexus from ALB"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "SSH from bastion"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "Internal VPC traffic only"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = merge(var.tags, {
    Name = "${var.environment}-ci-cd-nexus-sg"
  })
}

#---------------------- Jenkins SG ----------------------
module "jenkins_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.environment}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = module.alb.security_group_id
      description              = "Jenkins from ALB"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "SSH from admin IP"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ] 

  tags = merge(var.tags, {
    Name = "${var.environment}-jenkins-sg"
  })

}

# ---------------------- DB SG ----------------------
# module "db_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.3"

#   name        = "${var.environment}-db-sg"
#   description = "Security group for PostgreSQL database"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 5432
#       to_port                  = 5432
#       protocol                 = "tcp"
#       description              = "DB access from app layer"
#       source_security_group_id = module.k8s_worker_sg.security_group_id
#     },

#     {
#     from_port                = 22
#     to_port                  = 22
#     protocol                 = "tcp"
#     description              = "SSH from bastion"
#     source_security_group_id = module.bastion_sg.security_group_id
#     }

#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "all-all"
#       description = "Internal VPC traffic only"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]
    
  
#   tags = merge(var.tags, {
#     Name = "${var.environment}-postgresql-sg"
#   })
# }

# # ---------------------- BASTION SG ----------------------
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.admin_ip
      from_port   = 22
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]


  tags = merge(var.tags, {
    Name = "${var.environment}-bastion-sg"
  })
}

# ###################### Ec2-Instance Module #########################################

# module "k8s-master" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "6.2.0"

#   for_each = toset(var.master_names)

#   name                   = "${var.environment}-${each.key}"

#   instance_type          = var.instance_type
#   ami                    = data.aws_ami.ubuntu.id 
#   key_name               = var.ssh_key_name        
#   vpc_security_group_ids = [module.k8s_master_sg.security_group_id]
#   monitoring             = true
#   subnet_id              = module.vpc.private_subnets[index(var.master_names, each.key) % length(module.vpc.private_subnets)]
#   user_data              = data.template_file.master_userdata[each.key].rendered

#   disable_api_termination = false #Allow termination
#   metadata_options = {
#     http_endpoint = "enabled"
#     http_tokens   = "required"
#   }
# root_block_device = {
#     encrypted   = true
#     volume_type = "gp3"
#     volume_size = var.master_volume_size
#   }

#   tags = merge(
#     var.tags,
#     {
#       Role        = "master"
#     }
#   )
# }

# module "k8s-workers" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "6.2.0"

#   for_each = toset(var.worker_names)

#   name    = "${var.environment}-${each.key}"

#   instance_type          = var.instance_type
#   ami                    = data.aws_ami.ubuntu.id 
#   key_name               = var.ssh_key_name        
#   vpc_security_group_ids = [module.k8s_worker_sg.security_group_id]
#   monitoring             = true
#   subnet_id              = module.vpc.private_subnets[index(var.worker_names, each.key) % length(module.vpc.private_subnets)]
#   user_data              = data.template_file.worker_userdata[each.key].rendered

#   disable_api_termination = false #Allow termination
#   metadata_options = {
#     http_endpoint = "enabled"
#     http_tokens   = "required"
#   }
#   root_block_device = {
#     encrypted   = true
#     volume_type = "gp3"
#     volume_size = var.worker_volume_size
#     }
  
#   tags = merge(
#     var.tags,
#     {
#       Role        = "worker"
#     }
#   )
# }

module "jenkins-server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.2.0"

  name                   = "${var.environment}-jenkins-server"
  instance_type          = var.jenkins_instance_type
  ami                    = data.aws_ami.ubuntu.id 
  key_name               = var.ssh_key_name        
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  monitoring             = true
  subnet_id              = module.vpc.private_subnets[1]
  user_data              = data.template_file.tools_userdata["jenkins"].rendered

  disable_api_termination = false #Allow termination
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device = {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.jenkins_volume_size
  }
  
  tags = merge(
    var.tags,
    {
      Role        = "Jenkins-server"
    }
  )
}

module "nexus-server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.2.0"

  name                   = "${var.environment}-nexus-server"
  instance_type          = var.nexus_instance_type
  ami                    = data.aws_ami.ubuntu.id 
  key_name               = var.ssh_key_name        
  vpc_security_group_ids = [module.nexus_sg.security_group_id]
  monitoring             = true
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = data.template_file.tools_userdata["nexus"].rendered

  disable_api_termination = false #Allow termination
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device = {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.nexus_volume_size
  }
  tags = merge(
    var.tags,
    {
      Role        = "Nexus-server"
    }
  )
}

module "bastion-host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.2.0"

  name                   = "${var.environment}-bastion-host"
  instance_type          = var.bastion_instance_type
  ami                    = data.aws_ami.ubuntu.id 
  key_name               = var.ssh_key_name        
  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = data.template_file.tools_userdata["bastion"].rendered

  disable_api_termination = false #Allow termination
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device = {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.bastion_volume_size
  }

  tags = merge(
    var.tags,
    {
      Role        = "bastion-host"
    }
  )
}

# module "db_server" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "6.2.0"

#   name                   = "${var.environment}-db-server"
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.db_instance_type
#   key_name               = var.ssh_key_name
#   subnet_id              = module.vpc.private_subnets[1]
#   vpc_security_group_ids = [module.db_sg.security_group_id]
#   monitoring             = true
#   user_data              = data.template_file.tools_userdata["db"].rendered

#   disable_api_termination = false #Allow termination
#   metadata_options = {
#     http_endpoint = "enabled"
#     http_tokens   = "required"
#   }

#   root_block_device = {
#       encrypted   = true
#       volume_size = var.db_volume_size
#       volume_type = "gp3"
#     }

#   tags = merge(var.tags, {
#     Role = "database"
#   })
# }







