module "sa-google-cas-issuer" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = var.project_id
  name       = "sa-google-cas-issuer"
}

