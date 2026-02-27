resource "google_cloud_scheduler_job" "job" {
  name             = "weekly-recap-${var.environment}"
  description      = "Weekly watch recap generator"
  schedule         = "0 9 * * 1"
  time_zone        = "Europe/Berlin"
  region           = var.region

  http_target {
    http_method = "GET"
    uri         = var.target_uri

    oidc_token {
      service_account_email = var.service_account_email
    }
  }
}
