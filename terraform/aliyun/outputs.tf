output "public_ip" {
  description = "Public IP of the demo ECS instance"
  value       = alicloud_instance.aiops.public_ip
}

output "instance_id" {
  value = alicloud_instance.aiops.id
}

output "security_group_id" {
  value = alicloud_security_group.aiops.id
}
