# API Proxy module — Cloud Run service + service account + App Check

locals {
  service_name = "neonvoyager-api-proxy-${var.environment}"
  image_url    = "${var.region}-docker.pkg.dev/${var.project_id}/neonvoyager/api-proxy:${var.image_tag}"
}

# ── Service account ──────────────────────────────────────────────────────────

resource "google_service_account" "api_proxy" {
  project      = var.project_id
  account_id   = "nv-api-proxy-${var.environment}"
  display_name = "Neon Voyager API Proxy (${var.environment})"
}

# Allow the SA to access secrets
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api_proxy.email}"
}

# ── Cloud Run service ─────────────────────────────────────────────────────────

resource "google_cloud_run_v2_service" "api_proxy" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name     = local.service_name

  template {
    service_account = google_service_account.api_proxy.email

    scaling {
      min_instance_count = 0   # Scale to zero — $0 when idle
      max_instance_count = 10
    }

    containers {
      image = local.image_url

      # Secrets injected as environment variables from Secret Manager
      env {
        name = "TMDB_API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.tmdb_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.gemini_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "OMDB_API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.omdb_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "APP_CHECK_ENABLED"
        value = "true"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      liveness_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 5
        period_seconds        = 30
      }
    }
  }

  depends_on = [var.apis_enabled]
}

# ── Allow all authenticated users to invoke (App Check handles real authz) ───

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.api_proxy.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ── Firebase App Check enforcement ───────────────────────────────────────────
# App Check is configured in the Firebase console and verified in-app (main.py).
# The project_id label here is used to link the Cloud Run service to Firebase.
resource "google_firebase_app_check_service_config" "app_check" {
  provider           = google-beta
  project            = var.project_id
  service_id         = "firebaseappcheck.googleapis.com"
  enforcement_mode   = "ENFORCED"
}
