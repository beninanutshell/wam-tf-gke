output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint"
  value       = local.cluster_endpoint
  depends_on = [
    /* Nominally, the endpoint is populated as soon as it is known to Terraform.
    * However, the cluster may not be in a usable state yet.  Therefore any
    * resources dependent on the cluster being up will fail to deploy.  With
    * this explicit dependency, dependent resources can wait for the cluster
    * to be up.
    */
    google_container_cluster.cluster,
    google_container_node_pool.node_pool,
  ]
}

output "identity_namespace" {
  description = "Workload Identity namespace"
  value       = "${var.gcp_project_id}.svc.id.goog"
  depends_on = [
    google_container_cluster.cluster
  ]
} 