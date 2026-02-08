# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# data "template_file" "master_userdata" {
#   for_each = toset(var.master_names)
#   template = file("${path.module}/Scripts/bootstrap.sh.tpl")

#   vars = {
#     hostname = "${var.environment}-${each.key}"
#     role     = "master"
#   }
# }
# data "template_file" "worker_userdata" {
#   for_each = toset(var.worker_names)
#   template = file("${path.module}/Scripts/bootstrap.sh.tpl")

#   vars = {
#     hostname = "${var.environment}-${each.key}"
#     role     = "worker"
#   }
# }

data "template_file" "tools_userdata" {
  for_each = {
    bastion  = "bastion-host"
    jenkins  = "jenkins-server"
    nexus    = "nexus-server"
    proxy    = "proxy-server"
    # db       = "db-server"
  }

  template = file("${path.module}/Scripts/bootstrap.sh.tpl")

  vars = {
    hostname = "${var.environment}-${each.key}"
    role     = each.value
  }
}
