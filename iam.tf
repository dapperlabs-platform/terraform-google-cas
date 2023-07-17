resource "google_privateca_ca_pool_iam_member" "certificate-requester-iam" {
  ca_pool = google_privateca_ca_pool.temporal-subordinate-ca-pool.id
  role    = "roles/privateca.certificateRequester"
  member  = module.sa-google-cas-issuer.iam_email
}
