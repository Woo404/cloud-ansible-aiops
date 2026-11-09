provider "alicloud" {
  region = var.region
}

resource "alicloud_security_group" "aiops" {
  name        = "${var.name_prefix}-sg"
  description = "AIOps demo security group (example)"
  vpc_id      = data.alicloud_vswitches.selected.vswitches[0].vpc_id
}

data "alicloud_vswitches" "selected" {
  ids = [var.vswitch_id]
}

resource "alicloud_security_group_rule" "ingress" {
  for_each = toset(["22", "8000", "3000", "9090", "9093"])

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${each.value}/${each.value}"
  priority          = 1
  security_group_id = alicloud_security_group.aiops.id
  cidr_ip           = var.allowed_cidr
}

resource "alicloud_security_group_rule" "egress_all" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.aiops.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "aiops" {
  instance_name              = "${var.name_prefix}-ecs"
  image_id                   = var.image_id
  instance_type              = var.instance_type
  security_groups            = [alicloud_security_group.aiops.id]
  vswitch_id                 = var.vswitch_id
  key_name                   = var.key_name
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  internet_max_bandwidth_out = 5

  tags = {
    Project = "cloud-ansible-aiops"
    Role    = "aiops-demo"
  }
}
