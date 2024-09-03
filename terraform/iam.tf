# Create the service account for CI/CD
resource "google_service_account" "ci_cd" {
  account_id   = "ci-cd-service-account"
  display_name = "CI/CD Service Account"
  project      = var.project_id
}

# Assign the 'Editor' role to the service account
resource "google_project_iam_member" "ci_cd_iam" {
  project = var.project_id
  role    = "roles/editor"  # Use a predefined role
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

# Create a key for the service account
resource "google_service_account_key" "ci_cd_key" {
  service_account_id = google_service_account.ci_cd.email
  key_algorithm      = "KEY_ALG_RSA_2048"
}