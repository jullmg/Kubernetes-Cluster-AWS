# Variable declaration

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "aws_availibility_zone" {
  type        = string
  default     = "ca-central-1a"
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "master_nodes_count" {
  description = "Number of worker nodes to be created"
  type        = number
  default     = "1"

}

variable "worker_nodes_count" {
  description = "Number of worker nodes to be created"
  type        = number
  default     = "2"

}

variable "kubernetes_control_plane" {
  description = "List of open input ports for the AWS security group"
  type        = list(any)
  default     = [["22", "22"], ["53", "53"], ["6443", "6443"], ["2379", "2380"], ["10250", "10250"], ["10257", "10257"], ["10259", "10259"], ["30000", "32767"]]
}

variable "kubernetes_workers" {
  description = "List of open input ports for the AWS security group (k8 workers)"
  type        = list(any)
  default     = [["22", "22"], ["53", "53"], ["10250", "10250"], ["30000", "32767"]]
}