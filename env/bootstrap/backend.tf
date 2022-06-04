terraform {
  backend "gcs" {
    bucket      = "wam-bkt-b-tfstate-63f8"
    prefix      = "terraform/application/wam-tf-gke/state/env/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
