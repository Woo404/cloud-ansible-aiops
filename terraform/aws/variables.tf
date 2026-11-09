variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 22.04 AMI for the region (look up with aws ec2 describe-images)"
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "name_prefix" {
  type    = string
  default = "aiops-demo"
}
