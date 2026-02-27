# Enable all required GCP APIs for Neon Voyager
# These must be enabled before any other modules can run.

locals {
  required_apis = [
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",
    "cloudfunctions.googleapis.com",
    "firebase.googleapis.com",
    "firebaseremoteconfig.googleapis.com",
    "cloudscheduler.googleapis.com",
    "appcheck.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}
