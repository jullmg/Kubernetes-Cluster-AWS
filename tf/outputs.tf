output "aws-ami-ubutu" {
  value = data.aws_ami.aws_ubuntu_ami.id
}

output "aws-eip-master" {
  value = aws_eip.master_eip[*].public_ip
}

output "aws-eip-workers" {
  value = aws_eip.worker_eip[*].public_ip
  # value = [ for k, public_ip in aws_eip.worker_eip.public_ip : public_ip ]
  # value = values(aws_eip.worker_eip)[*]
}
