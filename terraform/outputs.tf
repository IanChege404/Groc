output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "admin_service_account_email" {
  description = "The admin service account email"
  value       = google_service_account.admin.email
}

output "functions_service_account_email" {
  description = "The functions service account email"
  value       = google_service_account.functions.email
}

output "admin_bucket_name" {
  description = "The admin assets bucket name"
  value       = google_storage_bucket.admin.name
}

output "firestore_database_name" {
  description = "The Firestore database name"
  value       = google_firestore_database.default.name
}
