# Staging environment

terraform {
  # backend "gcs" {
  #   bucket = "streamscout-terraform-state"
  #   prefix = "environments/staging"
  # }
}

module "apis" {
  source      = "../../"
  project_id  = var.project_id
  region      = var.region
  environment = "staging"
}

module "secrets" {
  source       = "../../modules/secrets"
  project_id   = var.project_id
  region       = var.region
  apis_enabled = module.apis
}

module "ci_cd" {
  source       = "../../modules/ci-cd"
  project_id   = var.project_id
  region       = var.region
  apis_enabled = module.apis
}
