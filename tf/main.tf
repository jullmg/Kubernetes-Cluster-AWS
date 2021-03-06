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

  ami                    = data.aws_ami.aws_ubuntu_ami.id
  instance_type          = var.ec2_instance_type
  key_name               = "K8-cluster"
  vpc_security_group_ids = [aws_security_group.kubernetes_control_plane.id]
  // subnet_id = aws_subnet.kubernetes_subnet.id

  root_block_device {
    volume_size           = 15
    delete_on_termination = "true"
    tags                  = { Name = "K8-cluster" }
    volume_type           = "gp2"
  }

  tags = {
    Name = "Kubernetes master node"
  }

}


# Worker nodes
resource "aws_instance" "kworker" {
  ami = data.aws_ami.aws_ubuntu_ami.id
  instance_type = var.ec2_instance_type
  key_name               = "K8-cluster"
  count = 3
  vpc_security_group_ids = [aws_security_group.kubernetes_workers.id]
  //subnet_id = aws_subnet.kubernetes_subnet.id


  tags = {
    Name = "Kubernetes worker node ${count.index}"
  }

 root_block_device {
    volume_size           = 15
    delete_on_termination = "true"
    tags                  = { Name = "K8-cluster" }
    volume_type           = "gp2"
  }

}

# Elastic IPs
resource "aws_eip" "master_eip" {
  instance = aws_instance.kmaster.id
  vpc      = "true"
}

# Security groups
resource "aws_security_group" "kubernetes_control_plane" {
  name        = "kubernetes_control_plane"
  description = "Security Group for my kubernetes cluster project"
  //vpc_id      = aws_vpc.kubernetes_cluster.id

  dynamic "ingress" {
    for_each = var.kubernetes_control_plane
    //iterator = data

    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = "tcp"
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
}

resource "aws_security_group" "kubernetes_workers" {
  name        = "kubernetes_workers"
  description = "Security Group for my kubernetes cluster project (workers)"
  //vpc_id      = aws_vpc.kubernetes_cluster.id

  dynamic "ingress" {
    for_each = var.kubernetes_workers
    //iterator = data

    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = "tcp"
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
}

# Data
data "aws_ami" "aws_ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]

}

# Virtual Private Cloud

# resource "aws_internet_gateway" "kubernetes_gw" {
#   vpc_id = aws_vpc.kubernetes_cluster.id
# }

# resource "aws_vpc" "kubernetes_cluster" {
#   cidr_block = "172.16.0.0/16"
#   enable_dns_hostnames = "true"


#   tags = {
#     Name = "kubernetes-cluster"
#   }
# }

# resource "aws_subnet" "kubernetes_subnet" {
#   vpc_id            = aws_vpc.kubernetes_cluster.id
#   cidr_block        = "172.16.0.0/24"
#   availability_zone = "ca-central-1a"

#   tags = {
#     Name = "kubernetes_cluster"
#   }
# }

# resource "aws_network_interface" "kubernetes-network-int" {
#   subnet_id   = aws_subnet.kubernetes_subnet.id
#   private_ips = ["172.16.10.100"]

#   tags = {
#     Name = "kubernetes-network-int"
#   }
# }