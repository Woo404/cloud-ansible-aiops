# Alibaba Cloud ECS example (Terraform)

Example only. Creates one ECS + security group. No remote state backend.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit
export ALICLOUD_ACCESS_KEY=...
export ALICLOUD_SECRET_KEY=...
terraform init
terraform plan
# terraform apply   # only on your own account
```

Then put `public_ip` into `ansible/inventory/aliyun.ini` and run the deploy playbook.
