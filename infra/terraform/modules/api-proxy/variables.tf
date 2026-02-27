variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Cloud Run region"
  default     = "europe-west1"
}

variable "environment" {
  type        = string
  description = "dev | staging | prod"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy (e.g. 'latest' or a git SHA)"
  default     = "latest"
}

variable "tmdb_secret_id" {
  type        = string
  description = "Secret Manager secret_id for the TMDB API key (from modules/secrets outputs)"
}

variable "gemini_secret_id" {
  type        = string
  description = "Secret Manager secret_id for the Gemini API key"
}

variable "omdb_secret_id" {
  type        = string
  description = "Secret Manager secret_id for the OMDb API key"
}

variable "apis_enabled" {
  type    = any
  default = null
}
