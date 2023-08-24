# Used in the certificate_authority_id setting as you cannot reuse the ID in the event that the CA gets recreated
# All variables in the keepers section would cause the CA resources to be recreated, thus if they are updated
# the random_string will also be updated and thus prevent an error from occuring when recreating the CAs.
resource "random_string" "rand" {
  length  = 8
  special = false

  keepers = {
    region                   = var.region
    root_organization        = var.root_config.organization
    root_organizational_unit = var.root_config.organizational_unit
    root_common_name         = var.root_config.common_name
    root_lifetime            = var.root_config.lifetime
    root_algorithm           = var.root_config.algorithm
    sub_organization         = var.subordinate_config.organization
    sub_organizational_unit  = var.subordinate_config.organizational_unit
    sub_common_name          = var.subordinate_config.common_name
    sub_lifetime             = var.subordinate_config.lifetime
    sub_algorithm            = var.subordinate_config.algorithm
  }
}

resource "google_privateca_ca_pool" "temporal-subordinate-ca-pool" {
  name     = "subordinate-ca-pool-${var.project_id}${var.pool_name_extension}"
  location = var.region
  tier     = "DEVOPS"
  project  = var.project_id
  publishing_options {
    publish_ca_cert = true
    publish_crl     = false
  }
  labels = {
    environment  = var.environment
    project_name = var.project_id
  }
}

resource "google_privateca_ca_pool" "temporal-root-ca-pool" {
  name     = "root-ca-pool-${var.project_id}${var.pool_name_extension}"
  location = var.region
  tier     = "DEVOPS"
  project  = var.project_id
  publishing_options {
    publish_ca_cert = true
    publish_crl     = false
  }
  labels = {
    environment  = var.environment
    project_name = var.project_id
  }
}

resource "google_privateca_certificate_authority" "temporal-root-ca" {
  certificate_authority_id = "root-ca-${var.project_id}-${random_string.rand.id}"
  location                 = random_string.rand.keepers.region
  pool                     = google_privateca_ca_pool.temporal-root-ca-pool.name
  config {
    subject_config {
      subject {
        organization        = random_string.rand.keepers.root_organization
        organizational_unit = random_string.rand.keepers.root_organizational_unit
        common_name         = random_string.rand.keepers.root_common_name
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
          server_auth = false
        }
      }
    }
  }
  type     = "SELF_SIGNED"
  lifetime = random_string.rand.keepers.root_lifetime
  # "946100000s"
  key_spec {
    algorithm = random_string.rand.keepers.root_algorithm
  }

  // Disable CA deletion related safe checks for easier cleanup.
  deletion_protection                    = var.deletion_protection
  skip_grace_period                      = var.skip_grace_period
  ignore_active_certificates_on_deletion = var.ignore_active_certificates_on_deletion
}

resource "google_privateca_certificate_authority" "temporal-subordinate-ca" {
  certificate_authority_id = "subordinate-ca-${var.project_id}-${random_string.rand.id}"
  location                 = random_string.rand.keepers.region
  pool                     = google_privateca_ca_pool.temporal-subordinate-ca-pool.name
  subordinate_config {
    certificate_authority = google_privateca_certificate_authority.temporal-root-ca.id
  }
  config {
    subject_config {
      subject {
        organization        = random_string.rand.keepers.sub_organization
        organizational_unit = random_string.rand.keepers.sub_organizational_unit
        common_name         = random_string.rand.keepers.sub_common_name
      }
    }
    x509_config {
      ca_options {
        is_ca = true
        # Force the sub CA to only issue leaf certs
        max_issuer_path_length = 0
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = false
          email_protection = true
          code_signing     = true
          time_stamping    = true
        }
      }
    }
  }
  type     = "SUBORDINATE"
  lifetime = random_string.rand.keepers.sub_lifetime
  key_spec {
    algorithm = random_string.rand.keepers.sub_algorithm
  }

  // Disable CA deletion related safe checks for easier cleanup.
  deletion_protection                    = var.deletion_protection
  skip_grace_period                      = var.skip_grace_period
  ignore_active_certificates_on_deletion = var.ignore_active_certificates_on_deletion
}

