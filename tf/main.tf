# To-do:
# Change security group source ips so that only nodes can communicate (not 0.0.0.0)
# unused network interfaces are created (too many)

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

provider "local" {
}

############################################
#### Resources #############################
############################################

################ Networking ################

resource "aws_vpc" "kubernetes_cluster" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "kubernetes-cluster"
  }
}

resource "aws_internet_gateway" "kubernetes_gw" {
  vpc_id = aws_vpc.kubernetes_cluster.id

  tags = {
    Name = "kubernetes-cluster"
  }
}

resource "aws_subnet" "kubernetes_subnet_1a" {
  vpc_id                  = aws_vpc.kubernetes_cluster.id
  cidr_block              = "172.16.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ca-central-1a"

  tags = {
    Name = "kubernetes_cluster_1a"
  }
}

resource "aws_subnet" "kubernetes_subnet_1b" {
  vpc_id                  = aws_vpc.kubernetes_cluster.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ca-central-1b"

  tags = {
    Name = "kubernetes_cluster_1b"
  }
}

# Route to internet gateway
resource "aws_route_table" "kubernetes_route" {
  vpc_id = aws_vpc.kubernetes_cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes_gw.id
  }

  tags = {
    Name = "kubernetes_cluster"

  }
}

# Need to associate internet gateway route to subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.kubernetes_subnet_1a.id
  route_table_id = aws_route_table.kubernetes_route.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.kubernetes_subnet_1b.id
  route_table_id = aws_route_table.kubernetes_route.id
}

resource "aws_network_interface" "kubernetes-masters-network-int" {
  count     = var.master_nodes_count
  subnet_id = aws_subnet.kubernetes_subnet_1a.id
  security_groups = [aws_security_group.kubernetes_control_plane.id]
  # private_ips = ["172.16.0.100"]

  tags = {
    Name = "kubernetes-masters-network-int"
  }
}

resource "aws_network_interface" "kubernetes-workers-network-int-1a" {
  count     = var.worker_nodes_count
  subnet_id = aws_subnet.kubernetes_subnet_1a.id
  security_groups = [aws_security_group.kubernetes_workers.id]

  tags = {
    Name = "kubernetes-workers-network-int"
  }
}

resource "aws_network_interface" "kubernetes-workers-network-int-1b" {
  count     = var.worker_nodes_count
  subnet_id = aws_subnet.kubernetes_subnet_1b.id
  security_groups = [aws_security_group.kubernetes_workers.id]

  tags = {
    Name = "kubernetes-workers-network-int"
  }
}

# Master node(s)
# vpc and subnet are set on network interface resource
resource "aws_instance" "kmaster" {
  ami               = data.aws_ami.aws_ubuntu_ami.id // Ubuntu Server 20.04LTS
  instance_type     = var.ec2_instance_type
  # availability_zone = var.aws_availibility_zone
  availability_zone = "ca-central-1a"
  key_name          = "K8-cluster"
  count             = var.master_nodes_count
  # vpc_security_group_ids = [aws_security_group.kubernetes_control_plane.id]
  # subnet_id              = aws_subnet.kubernetes_subnet.id

  network_interface {
    network_interface_id = aws_network_interface.kubernetes-masters-network-int[count.index].id
    device_index         = 0
  }

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
# vpc and subnet are set on network interface resource
resource "aws_instance" "kworker" {
  ami               = data.aws_ami.aws_ubuntu_ami.id
  instance_type     = var.ec2_instance_type
  # availability_zone = var.aws_availibility_zone
  availability_zone = count.index % 2 == 0 ? var.aws_availibility_zone[0] : var.aws_availibility_zone[1]
  key_name          = "K8-cluster"
  count             = var.worker_nodes_count
  # vpc_security_group_ids = [aws_security_group.kubernetes_workers.id]
  # subnet_id = aws_subnet.kubernetes_subnet.id


  tags = {
    Name = "Kubernetes worker node ${count.index}"
  }

  network_interface {
    network_interface_id = count.index % 2 == 0 ? aws_network_interface.kubernetes-workers-network-int-1a[count.index].id : aws_network_interface.kubernetes-workers-network-int-1b[count.index].id
    device_index         = 0
    
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
  count    = var.master_nodes_count
  instance = aws_instance.kmaster[count.index].id
  vpc      = "true"
  tags     = { Name = "K8-cluster" }
}

resource "aws_eip" "worker_eip" {
  count    = var.worker_nodes_count
  instance = aws_instance.kworker[count.index].id
  vpc      = "true"
  tags     = { Name = "K8-cluster" }
}


# Security groups
resource "aws_security_group" "kubernetes_control_plane" {
  name        = "kubernetes_control_plane"
  description = "Security Group for my kubernetes cluster project"
  vpc_id      = aws_vpc.kubernetes_cluster.id

  dynamic "ingress" {
    for_each = var.kubernetes_control_plane
    //iterator = data

    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = ingress.value[2]
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
  vpc_id      = aws_vpc.kubernetes_cluster.id

  dynamic "ingress" {
    for_each = var.kubernetes_workers
    //iterator = data

    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = ingress.value[2]
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

# generate inventory file for Ansible
resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      master_ip = aws_eip.master_eip[*].public_ip
      workers_ip = aws_eip.worker_eip[*].public_ip
    }
  )
  filename = "../Ansible/inventory"
}



