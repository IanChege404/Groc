variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "firestore_location" {
  description = "The Firestore location"
  type        = string
  default     = "us-central"
}

variable "admin_domain" {
  description = "The admin dashboard domain"
  type        = string
}

variable "environment" {
  description = "Environment (production, staging, development)"
  type        = string
  default     = "production"
}
