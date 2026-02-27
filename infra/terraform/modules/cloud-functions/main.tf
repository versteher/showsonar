locals {
  source_dir  = "${path.root}/../../../functions"
  output_path = "${path.root}/../../../.terraform/functions.zip"
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_path
  excludes    = ["node_modules", ".git", "lib"]
}

resource "google_storage_bucket" "function_source" {
  name                        = "${var.project_id}-${var.environment}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_zip.output_path
}

resource "google_service_account" "cloud_function_sa" {
  account_id   = "gcf-notification-sa-${var.environment}"
  display_name = "Cloud Function Notification Service Account"
}

resource "google_project_iam_member" "firestore_reader" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_project_iam_member" "firebase_admin" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_project_iam_member" "eventarc_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

# The Cloud Run service identity needs permission to write logs.
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_cloudfunctions2_function" "notification_trigger" {
  name        = "notification-trigger-${var.environment}"
  location    = var.region
  description = "Trigger notifications on Firestore releases write"

  build_config {
    runtime     = "nodejs20"
    entry_point = "onReleaseWritten"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.cloud_function_sa.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.firestore.document.v1.written"
    event_filters {
      attribute = "database"
      value     = "(default)"
    }
    event_filters {
      attribute = "document"
      value     = "releases/{releaseId}"
    }
    service_account_email = google_service_account.cloud_function_sa.email
    retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
  }
}

resource "google_cloudfunctions2_function" "weekly_recap" {
  name        = "weekly-recap-${var.environment}"
  location    = var.region
  description = "Triggered via Cloud Scheduler to generate weekly watch recaps"

  build_config {
    runtime     = "nodejs20"
    entry_point = "generateWeeklyRecap"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.cloud_function_sa.email
  }
}
