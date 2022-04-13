module "gke-cluster" {
  source = "../../modules/gke"

  gcp_project_id                      = var.gcp_project_id
  cluster_name                        = var.cluster_name
  gcp_location                        = var.gcp_location
  daily_maintenance_window_start_time = var.daily_maintenance_window_start_time
  node_pools                          = var.node_pools
  vpc_network_name                    = var.vpc_network_name
  vpc_subnetwork_name                 = var.vpc_subnetwork_name
  services_secondary_range_name       = var.services_secondary_range_name
  cluster_secondary_range_name        = var.cluster_secondary_range_name
  node_locations                      = var.node_locations
  labels                              = var.labels
  enable_dataplane_v2                 = false
  node_pool_additional_labels_i       = var.node_pool_additional_labels_i
  authenticator_security_group        = var.authenticator_security_group
  workload_pool                       = var.workload_pool
}

