# Variable declaration

variable "aws_region" {
  description = "AWS region"
  type = string
  default = "ca-central-1"
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type = string
  default = "t2.medium"
  
}