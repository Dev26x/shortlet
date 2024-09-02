resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "trace" {
  project = var.project_id
  service = "cloudtrace.googleapis.com"
}

resource "google_project_service" "profiler" {
  project = var.project_id
  service = "cloudprofiler.googleapis.com"
}
