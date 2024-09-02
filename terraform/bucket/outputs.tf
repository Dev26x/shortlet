output "terraform_state_bucket" {
  description = "GCS bucket name"
  value        = google_storage_bucket.terraform_state
}