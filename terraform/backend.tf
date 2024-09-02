terraform {
  backend "gcs" {
    bucket  = "shortlet-iac-project-terraform_state"          
    prefix  = "terraform/state"           
    encryption_key = null
  }
}
