terraform {
  backend "gcs" {
    bucket      = "wam-gcs-b-tfstate-2ac5"
    prefix      = "terraform/wam-tf-gke/state/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
