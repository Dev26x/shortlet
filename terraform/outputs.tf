output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "gke_master_version" {
  value = google_container_cluster.primary.master_version
}
