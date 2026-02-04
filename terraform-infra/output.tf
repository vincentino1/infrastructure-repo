# output "k8s_master_sg_id" {
#   value       = module.k8s_master_sg.security_group_id
#   description = "The ID of the Kubernetes master security group"
# }

# output "k8s_worker_sg_id" {
#   value       = module.k8s_worker_sg.security_group_id
#   description = "The ID of the Kubernetes worker security group"
# }

# output "nexus_sg_id" {
#   value       = module.nexus_sg.security_group_id
#   description = "The ID of the Nexus server security group"
# }

# output "db_sg_id" {
#   value       = module.db_sg.security_group_id
#   description = "The ID of the database security group"
# }

# output "bastion_sg_id" {
#   value       = module.bastion_sg.security_group_id
#   description = "The ID of the bastion host security group"
# }

# output "vpc_id" {
#   value       = module.vpc.vpc_id
#   description = "The ID of the VPC"
# }

# output "public_subnets_id" {
#   value       = module.vpc.public_subnets
#   description = "The IDs of the public subnets"
# }

# output "private_subnets_id" {
#   value       = module.vpc.private_subnets
#   description = "The IDs of the private subnets"
# }

# output "k8s_master_private_ips" {
#   value = [for inst in module.k8s-master : inst.private_ip]
# }

# output "k8s_worker_private_ips" {
#   value = [for inst in module.k8s-workers : inst.private_ip]
# }

output "jenkins_server_private_ip" {
  value       = module.jenkins-server.private_ip
  description = "The private IP address of the Jenkins server"
}

output "nexus_server_private_ip" {
  value       = module.nexus-server.private_ip
  description = "The private IP address of the Nexus server"
}

# output "db_server_private_ip" {
#   value       = module.db_server.private_ip
#   description = "The private IP address of the database server"
# }

output "bastion_host_public_ip" {
  value       = module.bastion-host.public_ip
  description = "The public IP address of the bastion host"
}

output "bastion_ssh_command" {
  value = "ssh -i ~/.ssh/my-project-key.pem ubuntu@${module.bastion-host.public_ip}"
}


