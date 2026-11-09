terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# EXAMPLE ONLY — no remote state backend.
# Prefer AWS_PROFILE / SSO; never commit access keys.
