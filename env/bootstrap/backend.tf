terraform {
  backend "gcs" {
    bucket      = "it-demo-app-tfstate-9c03"
    prefix      = "terraform/wam-tf-gke/state/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
