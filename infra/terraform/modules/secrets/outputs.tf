output "tmdb_secret_id" {
  description = "Secret Manager secret_id for the TMDB API key"
  value       = google_secret_manager_secret.tmdb_api_key.secret_id
}

output "gemini_secret_id" {
  description = "Secret Manager secret_id for the Gemini API key"
  value       = google_secret_manager_secret.gemini_api_key.secret_id
}

output "omdb_secret_id" {
  description = "Secret Manager secret_id for the OMDb API key"
  value       = google_secret_manager_secret.omdb_api_key.secret_id
}

output "tmdb_secret_name" {
  description = "Full resource name for the TMDB secret (used by Cloud Run env var injection)"
  value       = google_secret_manager_secret.tmdb_api_key.name
}

output "gemini_secret_name" {
  description = "Full resource name for the Gemini secret"
  value       = google_secret_manager_secret.gemini_api_key.name
}

output "omdb_secret_name" {
  description = "Full resource name for the OMDb secret"
  value       = google_secret_manager_secret.omdb_api_key.name
}
