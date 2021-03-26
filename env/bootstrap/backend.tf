terraform {
  backend "gcs" {
    bucket      = "wam-tfstate-7640"
    prefix      = "terraform/wam-tf-gke/state/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
