variable "region" {
  description = "The GCP region to deploy the resources"
  type        = string
  default     = "us-west1"
}

variable "project_id" {
  description = "The ID of the GCP project to deploy the resources"
  type        = string
}

variable "environment" {
  description = "The environment to deploy into (e.g. staging, production, sandbox...)"
  type        = string
}

variable "root_config" {
  description = "Settings for the Root CA that is created by the module"
  type = object({
    organization        = string
    organizational_unit = optional(string)
    common_name         = string
    lifetime            = string
    algorithm           = string
  })
}


variable "subordinate_config" {
  description = "Settings for the Root CA that is created by the module"
  type = object({
    organization        = string
    organizational_unit = optional(string)
    common_name         = string
    lifetime            = string
    algorithm           = string
  })
}

variable "deletion_protection" {
  description = "If set to true, it will prevent Terraform from deleting the CAs"
  type        = bool
  default     = true
}

variable "skip_grace_period" {
  description = "If set to true, CA will be deleted immediatedly, otherwise there will be a 30-day grace period."
  type        = bool
  default     = false
}

variable "ignore_active_certificates_on_deletion" {
  description = "If set to true, allows the CA to be deleted even if it has active certificates."
  type        = bool
  default     = false
}
