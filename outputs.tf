output "sa_email" {
  description = "The email of the service account with the permissions to request certificates from the subordinate CA pool."
  value       = module.sa-google-cas-issuer.email
}
