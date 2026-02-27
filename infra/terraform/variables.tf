variable "project_id" {
  type        = string
  description = "GCP project ID (e.g. neonvoyager-dev)"
}

variable "region" {
  type        = string
  description = "Primary GCP region for all resources"
  default     = "europe-west1"
}

variable "environment" {
  type        = string
  description = "Deployment environment: dev | staging | prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod"
  }
}
