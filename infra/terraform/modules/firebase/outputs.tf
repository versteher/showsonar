output "firebase_project_id" {
  description = "The GCP project ID with Firebase enabled"
  value       = google_firebase_project.default.project
}

output "android_app_id" {
  description = "Firebase Android app ID (used for App Check and google-services.json download)"
  value       = google_firebase_android_app.streamscout.app_id
}

output "ios_app_id" {
  description = "Firebase iOS app ID (used for App Check and GoogleService-Info.plist download)"
  value       = google_firebase_apple_app.streamscout.app_id
}
