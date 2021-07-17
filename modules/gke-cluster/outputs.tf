/******************************************
  Google container cluster outputs
******************************************/

output "gke_id" {
  value       = google_container_cluster.gke_cluster.id
  description = "The ID for the gke cluster."
}

output "gke_name" {
  value       = google_container_cluster.gke_cluster.name
  description = "The name for the gke cluster."
}

output "gke_location" {
  value       = google_container_cluster.gke_cluster.location
  description = "The location of the gke cluster."
}

output "gke_tpu_ipv4_cidr_block" {
  value       = google_container_cluster.gke_cluster.tpu_ipv4_cidr_block
  description = "The CIDR range of the TPU from this cluster's Kubernetes."
}

output "gke_master_ipv4_cidr_block" {
  value       = google_container_cluster.gke_cluster.private_cluster_config[0].master_ipv4_cidr_block
  description = "The IP address of this cluster's Kubernetes master."
}
