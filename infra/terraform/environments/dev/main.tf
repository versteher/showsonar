# Dev environment — wires the root modules together.
# Run from this directory: terraform init && terraform plan && terraform apply

terraform {
  # Uncomment after creating the GCS state bucket:
  # backend "gcs" {
  #   bucket = "showsonar-terraform-state"
  #   prefix = "environments/dev"
  # }
}

module "apis" {
  source      = "../../"
  project_id  = var.project_id
  region      = var.region
  environment = "dev"
}

module "secrets" {
  source             = "../../modules/secrets"
  project_id         = var.project_id
  region             = var.region
  apis_enabled       = module.apis
  api_proxy_sa_email = module.api_proxy.service_account_email
}

module "ci_cd" {
  source             = "../../modules/ci-cd"
  project_id         = var.project_id
  region             = var.region
  apis_enabled       = module.apis
  api_proxy_sa_email = module.api_proxy.service_account_email
  github_owner       = "jan-brink" # Placeholder, configure as appropriate
  github_repo        = "imdb"
}

module "api_proxy" {
  source           = "../../modules/api-proxy"
  project_id       = var.project_id
  region           = var.region
  environment      = "dev"
  apis_enabled     = module.apis
  tmdb_secret_id   = module.secrets.tmdb_secret_id
  gemini_secret_id = module.secrets.gemini_secret_id
  omdb_secret_id   = module.secrets.omdb_secret_id
}

module "firebase" {
  source       = "../../modules/firebase"
  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  apis_enabled = module.apis
}

module "firebase_auth" {
  source     = "../../modules/firebase-auth"
  project_id = var.project_id

  # OAuth credentials for Google and Apple Sign-In
  # Left empty by default, allowing Email/Password to work immediately.
  # google_client_id     = ""
  # google_client_secret = ""
  # apple_client_id      = ""
  # apple_team_id        = ""
  # apple_key_id         = ""
  # apple_private_key    = ""
}

module "firestore" {
  source     = "../../modules/firestore"
  project_id = var.project_id
  region     = var.region

  depends_on = [module.firebase]
}

module "cloud_functions" {
  source      = "../../modules/cloud-functions"
  project_id  = var.project_id
  region      = var.region
  environment = "dev"

  depends_on = [module.firestore]
}

module "scheduler" {
  source                = "../../modules/scheduler"
  project_id            = var.project_id
  region                = var.region
  environment           = "dev"
  target_uri            = module.cloud_functions.weekly_recap_uri
  service_account_email = "gcf-notification-sa-dev@${var.project_id}.iam.gserviceaccount.com" # Service Account from Cloud Functions module

  depends_on = [module.cloud_functions]
}

output "proxy_url" {
  description = "Cloud Run proxy URL — put this in Flutter ApiConfig"
  value       = module.api_proxy.service_url
}

output "firebase_android_app_id" {
  description = "Firebase Android app ID (for google-services.json download)"
  value       = module.firebase.android_app_id
}

output "firebase_ios_app_id" {
  description = "Firebase iOS app ID (for GoogleService-Info.plist download)"
  value       = module.firebase.ios_app_id
}
