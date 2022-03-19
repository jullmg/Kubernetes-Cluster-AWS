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
resource "aws_instance" "kmaster01" {
  // ami = "ami-0aee2d0182c9054ac" // Ubuntu Server 20.04LTS
  ami = data.aws_ami.aws_ubuntu_ami.id
  instance_type = var.ec2_instance_type
  key_name               = "K8-cluster"

}

data "aws_ami" "aws_ubuntu_ami" {
  most_recent = true

  filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  owners = ["099720109477"]

}