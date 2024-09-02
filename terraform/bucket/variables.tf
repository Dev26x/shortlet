variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "shortlet-iac-project"
}

variable "region" {
  description = "GCP zone"
  type        = string
  default = "us-central1"
}