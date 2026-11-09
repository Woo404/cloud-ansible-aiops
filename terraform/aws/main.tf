provider "aws" {
  region = var.region
}

resource "aws_security_group" "aiops" {
  name        = "${var.name_prefix}-sg"
  description = "AIOps demo security group (example)"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset([22, 8000, 3000, 9090, 9093])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "cloud-ansible-aiops"
  }
}

resource "aws_instance" "aiops" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.aiops.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.name_prefix}-ec2"
    Project = "cloud-ansible-aiops"
  }
}
