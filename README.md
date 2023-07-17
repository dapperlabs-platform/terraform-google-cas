# Terraform Google CAS

Terraform code for managing Google's Certificate Authority Service and IAM permissions on those resources.

## Example Usage

```
locals {
  organization        = "Dapper Labs"
  organizational_unit = "SRE"
  lifetime            = "946100000s" # ~30 years
  algorithm           = "EC_P256_SHA256"
  common_name_prefix  = "sre-sandbox-ca"
}

module "private-ca" {
  source = "github.com/dapperlabs-platform/terraform-google-cas?ref=instantiate-module"

  region      = var.default_region
  project_id  = var.project_name
  environment = var.environment
  root_config = {
    organization        = local.organization
    organizational_unit = local.organizational_unit
    common_name         = "${local.common_name_prefix}-temporal-2023"
    lifetime            = local.lifetime
    algorithm           = local.algorithm
  }

  subordinate_config = {
    organization        = local.organization
    organizational_unit = local.organizational_unit
    common_name         = "${local.common_name_prefix}-sub-temporal-2023"
    lifetime            = local.lifetime
    algorithm           = local.algorithm
  }

  deletion_protection                    = false
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
}
```

### What this creates....

- 2 Certificate Authority Pools, one for the root CA and one for the subordinate CAs. 
- A root CA in the root CA pool
- A subordinate CA in the subordinate CA pool
- A service account
- And IAM binding that grants the serice account `privateca.certificateRequester` on the subordinate CA pool
