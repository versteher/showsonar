variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Resource region"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "target_uri" {
  description = "Cloud Function URI to invoke"
  type        = string
}

variable "service_account_email" {
  description = "Service account email to use for OIDC authentication"
  type        = string
}
