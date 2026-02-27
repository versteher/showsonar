variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region for secret replication"
  default     = "europe-west1"
}

variable "api_proxy_sa_email" {
  type        = string
  description = "Service account email for the Cloud Run API proxy (created in modules/api-proxy)"
  default     = ""
  # Leave empty until P0-5 creates the service account.
  # When non-empty, IAM bindings are created automatically.
}

variable "apis_enabled" {
  # Dependency token — pass google_project_service.apis to ensure
  # the secretmanager API is enabled before creating secrets.
  type    = any
  default = null
}
