variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "google_client_id" {
  description = "Client ID for Google Sign-In"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Client Secret for Google Sign-In"
  type        = string
  default     = ""
  sensitive   = true
}

variable "apple_client_id" {
  description = "Client ID (Service ID) for Apple Sign-In"
  type        = string
  default     = ""
}

variable "apple_team_id" {
  description = "Team ID for Apple Sign-In"
  type        = string
  default     = ""
}

variable "apple_key_id" {
  description = "Key ID for Apple Sign-In"
  type        = string
  default     = ""
}

variable "apple_private_key" {
  description = "Private Key for Apple Sign-In"
  type        = string
  default     = ""
  sensitive   = true
}
