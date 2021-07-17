/***************************************************
  Backend GCS
****************************************************/
terraform {
  backend "gcs" {
    bucket = "wam-tfstate-7640"
    prefix = "terraform/wam-tf-gke/demo/gcp-node-pool"
  }
}
