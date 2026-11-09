terraform {
  required_version = ">= 1.5.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.225"
    }
  }
}

# EXAMPLE ONLY — no remote state backend configured.
# Do not commit access keys. Use env vars or a credentials file outside git:
#   export ALICLOUD_ACCESS_KEY=...
#   export ALICLOUD_SECRET_KEY=...
#   export ALICLOUD_REGION=cn-hangzhou
