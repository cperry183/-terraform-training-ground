output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.lab1.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_eip.lab1.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.lab1.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.lab1.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i /path/to/${var.key_name}.pem ubuntu@${aws_eip.lab1.public_ip}"
}

output "ami_id" {
  description = "The AMI ID used for the instance"
  value       = data.aws_ami.ubuntu.id
}
