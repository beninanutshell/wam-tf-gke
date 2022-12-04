terraform {
  backend "gcs" {
    bucket      = "it-lab-app-build-state-wam-it-c-iac-pipeline-0rqb"
    prefix      = "terraform/app/labo-gke/wam-tf-gke/state/env/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
