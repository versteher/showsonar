output "service_url" {
  description = "The HTTPS URL of the deployed Cloud Run API proxy"
  value       = google_cloud_run_v2_service.api_proxy.uri
}

output "service_account_email" {
  description = "Service account email (used by modules/secrets and modules/ci-cd IAM bindings)"
  value       = google_service_account.api_proxy.email
}
