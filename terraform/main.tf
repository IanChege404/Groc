terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "groc-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "services" {
  for_each = toset([
    "firebase.googleapis.com",
    "firestore.googleapis.com",
    "firebaseauth.googleapis.com",
    "identitytoolkit.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "sentry.io",
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# Firebase Project
resource "google_firebase_project" "default" {
  provider = google
  project  = var.project_id

  depends_on = [google_project_service.services]
}

# Firestore Database
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_firebase_project.default]
}

# Firebase Auth
resource "google_firebase_project_location" "default" {
  project        = var.project_id
  location_id    = var.region

  depends_on = [google_firebase_project.default]
}

# Service Account for Admin
resource "google_service_account" "admin" {
  account_id   = "groc-admin"
  display_name = "Groc Admin Service Account"
  description  = "Service account for Groc Admin Dashboard"
}

resource "google_project_iam_member" "admin_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.admin.email}"
}

resource "google_project_iam_member" "admin_auth" {
  project = var.project_id
  role    = "roles/firebaseauth.admin"
  member  = "serviceAccount:${google_service_account.admin.email}"
}

# Service Account for Firebase Functions
resource "google_service_account" "functions" {
  account_id   = "groc-functions"
  display_name = "Groc Firebase Functions"
  description  = "Service account for Firebase Cloud Functions"
}

resource "google_project_iam_member" "functions_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.functions.email}"
}

# Cloud Storage Bucket for Admin
resource "google_storage_bucket" "admin" {
  name          = "${var.project_id}-admin-assets"
  location      = var.region
  force_destroy = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# Monitoring Uptime Check
resource "google_monitoring_uptime_check_config" "admin" {
  display_name = "Admin Dashboard Uptime"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.admin_domain
    }
  }
}

# Alert Policy for Errors
resource "google_monitoring_alert_policy" "admin_errors" {
  display_name = "Admin Dashboard Error Rate"
  combiner     = "OR"

  conditions {
    display_name = "Error rate > 5%"
    condition_threshold {
      filter          = "resource.type = \"gae_app\" AND severity >= ERROR"
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = []

  alert_strategy {
    auto_close = "1800s"
  }
}
