provider "google" {
  project = var.project_id
  region = var.region
}

resource "google_storage_bucket" "terraform_state" {
  name     = "${var.project_id}-terraform_state"
  location = "us-central1"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }

  # Enable uniform bucket-level access
  uniform_bucket_level_access = true
}

output "gcs_bucket_name" {
  value = google_storage_bucket.terraform_state.name
}
