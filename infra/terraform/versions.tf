terraform {
  required_version = ">= 1.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.20"
    }
  }

  # Remote state in GCS — created by the bootstrap script in WORLD_CLASS_ANALYSIS.md
  # Uncomment once the bucket exists:
  # backend "gcs" {
  #   bucket = "streamscout-terraform-state"
  #   prefix = "terraform/state"
  # }
}
