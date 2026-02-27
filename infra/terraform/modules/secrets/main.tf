# Secret Manager module
# Creates one Secret Manager secret per API key.
# Actual secret values are stored out-of-band via:
#   gcloud secrets versions add <name> --data-file=- <<< "your_key_here"

resource "google_secret_manager_secret" "tmdb_api_key" {
  project   = var.project_id
  secret_id = "tmdb-api-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [var.apis_enabled]
}

resource "google_secret_manager_secret" "gemini_api_key" {
  project   = var.project_id
  secret_id = "gemini-api-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [var.apis_enabled]
}

resource "google_secret_manager_secret" "omdb_api_key" {
  project   = var.project_id
  secret_id = "omdb-api-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [var.apis_enabled]
}

# Grant the Cloud Run service account access to read all 3 secrets (used by P0-5)
resource "google_secret_manager_secret_iam_member" "tmdb_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.tmdb_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_proxy_sa_email}"
}

resource "google_secret_manager_secret_iam_member" "gemini_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_proxy_sa_email}"
}

resource "google_secret_manager_secret_iam_member" "omdb_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.omdb_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_proxy_sa_email}"
}
