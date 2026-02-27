# CI/CD module — Phase 1: Artifact Registry
# Phase 2 (Cloud Build trigger) is added in P1-5.

resource "google_artifact_registry_repository" "docker" {
  provider = google-beta

  project       = var.project_id
  location      = var.region
  repository_id = "neonvoyager"
  description   = "Docker images for Neon Voyager API proxy and Cloud Run services"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }

  depends_on = [var.apis_enabled]
}

# Grant Cloud Build the right to push images
resource "google_artifact_registry_repository_iam_member" "cloudbuild_writer" {
  provider = google-beta

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Grant Cloud Run the right to pull images
resource "google_artifact_registry_repository_iam_member" "cloudrun_reader" {
  provider = google-beta

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.api_proxy_sa_email}"
}

data "google_project" "project" {
  project_id = var.project_id
}

# CI/CD Trigger
resource "google_cloudbuild_trigger" "main_pipeline" {
  provider = google-beta
  project  = var.project_id
  name     = "neonvoyager-main-ci-cd"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"

  depends_on = [var.apis_enabled]
}

# Grant Cloud Build service account necessary roles for deployment
locals {
  cloudbuild_roles = [
    "roles/run.admin",           # Deploy Cloud Run
    "roles/iam.serviceAccountUser", # Run as service account
    "roles/datastore.owner",     # Deploy Firestore Rules (legacy Datastore role required)
    "roles/secretmanager.secretAccessor" # Potentially access secrets during build if needed
  ]
}

resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset(local.cloudbuild_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
