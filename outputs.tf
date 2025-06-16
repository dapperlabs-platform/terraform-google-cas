output "sa_email" {
  description = "The email of the service account with the permissions to request certificates from the subordinate CA pool."
  value       = module.sa-google-cas-issuer.email
}

output "ca_certs" {
  description = "The CA certificate chain for the subordinate CA."
  value       = google_privateca_certificate_authority.temporal-subordinate-ca.pem_ca_certificates
}
