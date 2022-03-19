# Initiate backend and provider
terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
      }
  }
}

# Provider config
provider "aws" {
  region = var.aws_region
}


# Resources

# Master node(s)
resource "aws_instance" "kmaster" {
  // ami = "ami-0aee2d0182c9054ac" // Ubuntu Server 20.04LTS
  
  ami = data.aws_ami.aws_ubuntu_ami.id
  instance_type = var.ec2_instance_type
  key_name               = "K8-cluster"
  vpc_security_group_ids = [aws_security_group.kubernetes_cluster.id]

  root_block_device {
    volume_size           = 15
    delete_on_termination = "false"
    tags                  = { Name = "K8-cluster" }
    volume_type           = "gp2"
  }

  tags = {
    Name = "Kubernetes master node"
  }

}

# Worker nodes
# resource "aws_instance" "kmaster" {
#   ami = data.aws_ami.aws_ubuntu_ami.id
#   instance_type = var.ec2_instance_type
#   key_name               = "K8-cluster"

#   tags = {
#     Name = "Kubernetes master node"
#   }

# }

# Elastic IPs
resource "aws_eip" "master_eip" {
  instance = aws_instance.kmaster.id
  vpc      = "true"
}

# Security group
resource "aws_security_group" "kubernetes_cluster" {
  name        = "kubernetes_security_group"
  description = "Security Group for my kubernetes cluster project"

  dynamic "ingress" {
    for_each = var.ingress_settings
    //iterator = data

    content {
      from_port = ingress.value["portfrom"]
      to_port   = ingress.value["portto"]
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


# Data
data "aws_ami" "aws_ubuntu_ami" {
  most_recent = true

  filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  owners = ["099720109477"]

}