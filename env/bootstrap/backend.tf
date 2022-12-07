terraform {
  backend "gcs" {
    bucket      = "devops-lab-app-build-state-wam-devops-c-iac-pipeline-pt78"
    prefix      = "terraform/app/devops/wam-tf-gke/state/env/bootstrap/"
    credentials = "terraform-deploy.json"
  }
}
