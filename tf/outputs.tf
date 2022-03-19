output "aws-ami-ubutu" {
    value = data.aws_ami.aws_ubuntu_ami.id
}