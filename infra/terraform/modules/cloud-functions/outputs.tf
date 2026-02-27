output "function_uri" {
  description = "URI of the Cloud Function"
  value       = google_cloudfunctions2_function.notification_trigger.service_config[0].uri
}

output "weekly_recap_uri" {
  description = "URI of the Weekly Recap Cloud Function"
  value       = google_cloudfunctions2_function.weekly_recap.service_config[0].uri
}
