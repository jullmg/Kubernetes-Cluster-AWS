output "aws-ami-ubutu" {
    value = data.aws_ami.aws_ubuntu_ami.id
}

output "aws-eip-master" {
    value = aws_eip.master_eip.public_ip
}