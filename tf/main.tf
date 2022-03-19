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

