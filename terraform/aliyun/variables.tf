variable "region" {
  type        = string
  description = "Alibaba Cloud region"
  default     = "cn-hangzhou"
}

variable "instance_type" {
  type        = string
  description = "ECS instance type"
  default     = "ecs.t6-c1m1.large"
}

variable "image_id" {
  type        = string
  description = "Ubuntu 22.04 image id for the chosen region (look up in console)"
  default     = "ubuntu_22_04_x64_20G_alibase_20240508.vhd"
}

variable "vswitch_id" {
  type        = string
  description = "Existing VSwitch id"
}

variable "key_name" {
  type        = string
  description = "Existing ECS key pair name"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH and app ports (tighten in real use)"
  default     = "0.0.0.0/0"
}

variable "name_prefix" {
  type    = string
  default = "aiops-demo"
}
