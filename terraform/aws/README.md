# AWS EC2 example (Terraform)

Example only. Creates one EC2 + security group. No remote state backend.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit
export AWS_PROFILE=your-profile
terraform init
terraform plan
# terraform apply
```

Then put `public_ip` into `ansible/inventory/aws.ini` and run the deploy playbook.
