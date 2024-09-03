output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "gke_master_version" {
  value = google_container_cluster.primary.master_version
}

output "application_url" {
  value = "http://${kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip}:80"
  description = "The URL of the application"
}

# Output the email of the CI/CD service account
output "ci_cd_service_account_email" {
  value = google_service_account.ci_cd.email
}

# Output the private key of the CI/CD service account key (sensitive)
output "ci_cd_service_account_key_private_key" {
  value     = google_service_account_key.ci_cd_key.private_key
  sensitive = true
}
