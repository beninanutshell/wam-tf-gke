/***************************************************
  Google container cluster
****************************************************/

resource "google_container_cluster" "gke_cluster" {
  provider = google-beta

  project = var.project_id

  /******************************************
  Cluster basics
******************************************/

  name           = var.name
  description    = var.description
  location       = var.location
  node_locations = var.node_locations

  release_channel {
    channel = var.channel
  }

  #checkovmin_master_version       = var.channel == "RAPID" ? data.google_container_engine_versions.region.latest_master_version : (var.channel == "REGULAR" ? data.google_container_engine_versions.region.valid_master_versions[3] : data.google_container_engine_versions.region.valid_master_versions[8])
  min_master_version       = "latest"
  remove_default_node_pool = true

  /******************************************
  Automation
******************************************/

  maintenance_policy {

    recurring_window {
      start_time = var.update_start_time
      end_time   = var.update_end_time
      recurrence = var.update_recurrence
    }

    dynamic "maintenance_exclusion" {
      for_each = var.maintenance_exclusion
      content {
        exclusion_name = maintenance_exclusion.value.exclusion_update_name
        start_time     = maintenance_exclusion.value.exclusion_update_start_time
        end_time       = maintenance_exclusion.value.exclusion_update_end_time
      }
    }
  }

  /* notification_config {
    pubsub {
      enabled = var.notification_config_topic != "" ? true : false
      topic   = var.notification_config_topic
    }
  } */

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  cluster_autoscaling {
    enabled = var.enable_cluster_autoscaling

    dynamic "auto_provisioning_defaults" {
      for_each = var.enable_cluster_autoscaling == true ? [1] : []

      content {
        service_account  = var.service_account
        oauth_scopes     = ["https://www.googleapis.com/auth/cloud-platform"]
        min_cpu_platform = var.min_cpu_platform
      }

    }

    autoscaling_profile = var.autoscaling_profile

    dynamic "resource_limits" {
      for_each = var.autoscaling_resource_limits
      content {
        resource_type = resource_limits.value.resource_type
        minimum       = resource_limits.value.minimum
        maximum       = resource_limits.value.maximum
      }
    }
  }

  /******************************************
  Networking
*******************************************/

  private_cluster_config {

    #checkov:skip=CKV_GCP_18:GKE Control Plane is public to ease the operation
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes    = var.enable_private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

    master_global_access_config {
      enabled = var.enable_master_global_access_config
    }

  }

  default_snat_status {
    disabled = var.disable_default_snat
  }

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  default_max_pods_per_node = var.default_max_pods_per_node

  enable_intranode_visibility = var.enable_intranode_visibility

  enable_l4_ilb_subsetting = var.enable_l4_ilb_subsetting

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_cidr_blocks_list
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  dynamic "network_policy" {
    for_each = var.cluster_network_policy == true ? [1] : []
    content {
      enabled  = true
      provider = "CALICO"
    }
  }

  /******************************************
  Security
*****************************************/

  enable_shielded_nodes = true
  /*
  database_encryption {
    state    = "ENCRYPTED"
    key_name = var.key_name
  }
*/
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  authenticator_groups_config {
    security_group = "gke-security-groups@${var.domain_cloud_identity}"
  }

  #checkov:skip=CKV_GCP_13:Client certificate used by clients to authenticate to Kubernetes Engine Clusters is disabled by default
  enable_legacy_abac = false
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  #checkov:skip=CKV_GCP_24:PSP are depracted in kubernetes 1.21 and delete in 1.25
  pod_security_policy_config {
    enabled = false
  }

  /******************************************
  Metadata
******************************************/

  #checkov:skip=CKV_GCP_21:Kubernetes Clusters are configured with Labels by the values in tfvars
  resource_labels = var.labels

  /******************************************
  Features
******************************************/

  #checkov:skip=CKV_GCP_1:Ensure Stackdriver Logging is set to Enabled on Kubernetes Engine Clusters
  #checkov:skip=CKV_GCP_8:Ensure Stackdriver Monitoring is set to Enabled on Kubernetes Engine Clusters
  monitoring_service      = var.cluster_telemetry_is_set != true ? var.monitoring_service : null
  logging_service         = var.cluster_telemetry_is_set != true ? var.logging_service : null
  enable_tpu              = var.enable_tpu
  enable_kubernetes_alpha = var.enable_kubernetes_alpha

  #checkov:skip=CKV_GCP_66: "Ensure use of Binary Authorization"
  enable_binary_authorization = var.enable_binary_authorization

  /* resource_usage_export_config {
    enable_network_egress_metering       = var.enable_network_egress_metering
    enable_resource_consumption_metering = var.enable_resource_consumption_metering
    bigquery_destination {
      dataset_id = var.dataset_id
    }
  } */

  dynamic "cluster_telemetry" {
    for_each = var.cluster_telemetry_is_set != true ? [] : [1]
    content {
      type = var.cluster_telemetry_type
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = var.disable_horizontal_pod_autoscaling
    }
    http_load_balancing {
      disabled = var.disable_http_load_balancing
    }

    network_policy_config {
      disabled = var.cluster_network_policy == true ? false : true
    }
    cloudrun_config {
      disabled = var.disable_cloudrun_config
    }
    istio_config {
      disabled = var.disable_istio_config
      auth     = var.auth
    }
    dns_cache_config {
      enabled = var.enable_dns_cache_config
    }
    gce_persistent_disk_csi_driver_config {
      enabled = var.enable_gce_persistent_disk_csi_driver_config
    }
    kalm_config {
      enabled = var.enable_kalm_config
    }
    config_connector_config {
      enabled = var.enable_config_connector_config
    }
  }

  /******************************************
  DATAPLANE_V2
******************************************/

  # datapath_provider supported values:
  ## "DATAPATH_PROVIDER_UNSPECIFIED"
  ## "LEGACY_DATAPATH"
  ## "ADVANCED_DATAPATH"
  # Network Policy must be disabled if DATAPLANE_V2 is setup
  # DV2 is GA in newly created clusters using GKE versions 1.20.6-gke.700 and later
  datapath_provider = var.cluster_network_policy == true ? null : "ADVANCED_DATAPATH"

  node_pool {

    name               = "default-pool"
    initial_node_count = 0

    node_config {
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      service_account = var.service_account

      #checkov:skip=CKV_GCP_69: Ensure the GKE Metadata Server is Enabled
      #checkov:skip=CKV_GCP_67: Legacy Compute Engine instance metadata APIs is Disabled
      workload_metadata_config {
        node_metadata = "GKE_METADATA_SERVER"
      }
      metadata = {
        disable-legacy-endpoints = "true"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      node_pool,
      maintenance_policy,
      node_locations,
    ]
  }

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }

}