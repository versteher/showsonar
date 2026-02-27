variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region for the Artifact Registry repository"
  default     = "europe-west1"
}

variable "api_proxy_sa_email" {
  type        = string
  description = "Service account email for the Cloud Run API proxy (for pull access)"
  default     = ""
}

variable "apis_enabled" {
  type    = any
  default = null
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner for Cloud Build trigger"
  default     = "neon-voyager"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name for Cloud Build trigger"
  default     = "imdb"
}
