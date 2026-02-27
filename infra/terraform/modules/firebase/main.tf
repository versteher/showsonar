# Firebase module (P0-7)
# Enables Firebase on the existing GCP project, registers the Android and iOS
# apps, and turns on Firebase App Check device-attestation enforcement.
#
# NOTE: google_firebase_* resources use the google-beta provider.
# The GCP project must already exist (created in P0-2).

# ── Firebase project ──────────────────────────────────────────────────────────
# Adds Firebase capabilities to the existing GCP project.
# If Firebase is already enabled on the project this resource becomes a no-op.

resource "google_firebase_project" "default" {
  provider   = google-beta
  project    = var.project_id
  depends_on = [var.apis_enabled]
}

# ── Android app ───────────────────────────────────────────────────────────────
# Bundle ID must match the value set in android/app/build.gradle.

resource "google_firebase_android_app" "neonvoyager" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Neon Voyager Android (${var.environment})"
  package_name = var.android_package_name

  depends_on = [google_firebase_project.default]
}

# ── iOS app ───────────────────────────────────────────────────────────────────
# Bundle ID must match the value in the Xcode project settings.

resource "google_firebase_apple_app" "neonvoyager" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Neon Voyager iOS (${var.environment})"
  bundle_id    = var.ios_bundle_id

  depends_on = [google_firebase_project.default]
}

# ── App Check: Android (Play Integrity) ───────────────────────────────────────
# Play Integrity is the recommended attestation provider for Android.
# token_ttl defaults to 1 hour ("3600s").

resource "google_firebase_app_check_play_integrity_config" "android" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_android_app.neonvoyager.app_id
  token_ttl = "3600s"

  depends_on = [google_firebase_android_app.neonvoyager]
}

# ── App Check: iOS (DeviceCheck) ──────────────────────────────────────────────
# DeviceCheck is the Apple-native attestation provider for iOS/macOS.
# Only provisioned when app_check_key_id is non-empty.
#
# To enable:
#   1. Generate a DeviceCheck key in the Apple Developer portal.
#   2. Set app_check_key_id + app_check_private_key in terraform.tfvars.
#   3. Re-run terraform apply.
#
# See: https://firebase.google.com/docs/app-check/ios/devicecheck-provider

resource "google_firebase_app_check_device_check_config" "ios" {
  count = var.app_check_key_id != "" ? 1 : 0

  provider    = google-beta
  project     = var.project_id
  app_id      = google_firebase_apple_app.neonvoyager.app_id
  key_id      = var.app_check_key_id
  private_key = var.app_check_private_key
  token_ttl   = "3600s"

  depends_on = [google_firebase_apple_app.neonvoyager]
}

# ── Remote Config ─────────────────────────────────────────────────────────────
# Defines the default feature flags for the application.
# These values will be delivered to the client automatically via the SDK.

resource "google_firebase_remote_config_template" "default" {
  provider = google-beta
  project  = var.project_id

  depends_on = [google_firebase_project.default]

  parameters {
    key = "enable_social"
    default_value {
      value = "false"
    }
    value_type = "BOOLEAN"
    description = "Enables social features like following friends and shared watchlists"
  }

  parameters {
    key = "enable_widgets"
    default_value {
      value = "false"
    }
    value_type = "BOOLEAN"
    description = "Enables home screen widget previews within the app UI"
  }
}
