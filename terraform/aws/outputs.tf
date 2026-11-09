output "public_ip" {
  description = "Public IP of the demo EC2 instance"
  value       = aws_instance.aiops.public_ip
}

output "instance_id" {
  value = aws_instance.aiops.id
}

output "security_group_id" {
  value = aws_security_group.aiops.id
}
