/***************************************************
  GKE versions
****************************************************/

data "google_container_engine_versions" "region" {
  provider       = google-beta
  project        = var.project_id
  location       = var.location
  version_prefix = "1.20."
}