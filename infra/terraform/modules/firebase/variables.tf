variable "project_id" {
  type        = string
  description = "GCP project ID (e.g. showsonar-dev)"
}

variable "environment" {
  type        = string
  description = "Deployment environment: dev | staging | prod"
}

variable "region" {
  type        = string
  description = "GCP region (informational only — Firebase resources are global)"
  default     = "europe-west1"
}

variable "android_package_name" {
  type        = string
  description = "Android application package name (e.g. com.showsonar.app)"
  default     = "com.showsonar.app"
}

variable "ios_bundle_id" {
  type        = string
  description = "iOS/macOS bundle identifier (e.g. com.showsonar.app)"
  default     = "com.showsonar.app"
}

variable "app_check_key_id" {
  type        = string
  description = "Apple DeviceCheck private key ID (10-character string from Apple Developer portal)"
  # Upload the corresponding .p8 key file in the Firebase console manually.
  # See: https://firebase.google.com/docs/app-check/ios/devicecheck-provider
  default     = ""
}

variable "app_check_private_key" {
  type        = string
  description = "Apple DeviceCheck private key contents (PEM string from the .p8 file)"
  sensitive   = true
  default     = ""
}

variable "apis_enabled" {
  # Dependency token — pass google_project_service.apis to ensure the
  # firebase.googleapis.com API is enabled before creating resources.
  type    = any
  default = null
}
