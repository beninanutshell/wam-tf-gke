terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.16.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

  }
}

# Local values assign a name to an expression, that can then be used multiple
# times within a module. They are used here to determine the GCP region from
# the given location, which can be either a region or zone.
locals {
  gcp_location_parts           = split("-", var.gcp_location)
  gcp_region                   = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])
  cluster_endpoint             = google_container_cluster.cluster.endpoint
  release_channel              = var.release_channel == "" ? [] : [var.release_channel]
  min_master_version           = var.release_channel == "" ? var.min_master_version : ""
  workload_pool                = var.workload_pool == "" ? [] : [var.workload_pool]
  authenticator_security_group = var.authenticator_security_group == "" ? [] : [var.authenticator_security_group]
  cluster_name                 = "${var.gcp_project_id}-kcl-${var.cluster_name}"
  cluster_labels               = merge(var.cluster_additional_labels, tomap(var.labels))
}

provider "google" {
  project = var.gcp_project_id
  region  = local.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = local.gcp_region
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_client_config" "default" {}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html
#tfsec:ignore:google-gke-enforce-pod-security-policy tfsec:ignore:google-gke-node-pool-uses-cos tfsec:ignore:google-gke-enable-network-policy
resource "google_container_cluster" "cluster" {

  provider           = google-beta
  location           = var.gcp_location
  project            = var.gcp_project_id
  node_locations     = var.node_locations
  name               = local.cluster_name
  min_master_version = local.min_master_version

  enable_shielded_nodes = "true"

  dynamic "release_channel" {
    for_each = toset(local.release_channel)

    content {
      channel = release_channel.value
    }
  }

  dynamic "authenticator_groups_config" {
    for_each = toset(local.authenticator_security_group)

    content {
      security_group = authenticator_groups_config.value
    }
  }

  # Configure workload identity if set
  dynamic "workload_identity_config" {
    for_each = toset(local.workload_pool)

    content {
      #workload_pool = workload_identity_config.value
      workload_pool = "${var.gcp_project_id}.svc.id.goog"
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_window_start_time
    }
  }

  # A set of options for creating a private cluster.
  private_cluster_config {
    enable_private_endpoint = var.private_endpoint
    enable_private_nodes    = var.private_nodes

    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  # Configuration options for the NetworkPolicy feature.
  network_policy {
    # Whether network policy is enabled on the cluster. Defaults to false.
    # In GKE this also enables the ip masquerade agent
    # https://cloud.google.com/kubernetes-engine/docs/how-to/ip-masquerade-agent
    enabled = var.enable_dataplane_v2 ? false : false
    # The selected network policy provider. Defaults to PROVIDER_UNSPECIFIED.
    #provider = "CALICO"
    provider = var.enable_dataplane_v2 ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }
  # This is where Dataplane V2 is enabled.
  datapath_provider = var.enable_dataplane_v2 ? "DATAPATH_PROVIDER_UNSPECIFIED" : "ADVANCED_DATAPATH"

  enable_legacy_abac = false
  master_auth {
    # Setting an empty username and password explicitly disables basic auth
    #username = ""
    #password = ""

    # Whether client certificate authorization is enabled for this cluster.
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # The configuration for addons supported by GKE.
  addons_config {
    http_load_balancing {
      disabled = var.http_load_balancing_disabled
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
    # Whether we should enable the network policy addon for the master. This must be
    # enabled in order to enable network policy for the nodes. It can only be disabled
    # if the nodes already do not have network policies enabled. Defaults to disabled;
    # set disabled = false to enable.
    network_policy_config {
      disabled = false
    }

    istio_config {
      disabled = true
      auth     = "AUTH_NONE"
    }

    gcp_filestore_csi_driver_config {
      enabled = var.filestore_csi_driver
    }

    gce_persistent_disk_csi_driver_config {
      enabled = var.gce_persistent_disk_csi_driver_config
    }

    kalm_config {
      enabled = false
    }

    config_connector_config {
      enabled = var.config_connector_config
    }
  }

  identity_service_config {
    enabled = false
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  network    = var.vpc_network_name
  subnetwork = var.vpc_subnetwork_name

  # Configuration for cluster IP allocation. As of now, only pre-allocated
  # subnetworks (custom type with secondary ranges) are supported. This will
  # activate IP aliases.
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  # It's not possible to create a cluster with no node pool defined, but we
  # want to only use separately managed node pools. So we create the smallest
  # possible default node pool and immediately delete it.
  remove_default_node_pool = true

  # The number of nodes to create in this cluster (not including the Kubernetes master).
  initial_node_count = 1

  # The desired configuration options for master authorized networks. Omit the
  # nested cidr_blocks attribute to disallow external access (except the
  # cluster node IPs, which GKE automatically whitelists).
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  node_config {

    service_account = google_service_account.default.email

  }

  # The loggingservice that the cluster should write logs to. Using the
  # 'logging.googleapis.com/kubernetes' option makes use of new Stackdriver
  # Kubernetes integration.
  logging_service = var.stackdriver_logging != "false" ? "logging.googleapis.com/kubernetes" : ""

  # The monitoring service that the cluster should write metrics to. Using the
  # 'monitoring.googleapis.com/kubernetes' option makes use of new Stackdriver
  # Kubernetes integration.
  monitoring_service = var.stackdriver_monitoring != "false" ? "monitoring.googleapis.com/kubernetes" : ""

  # Change how long update operations on the cluster are allowed to take
  # before being considered to have failed. The default is 10 mins.
  # https://www.terraform.io/docs/configuration/resources.html#operation-timeouts
  timeouts {
    update = "20m"
  }

  resource_labels = local.cluster_labels
}

# https://www.terraform.io/docs/providers/google/r/container_node_pool.html
#tfsec:ignore-google-gke-node-pool-uses-cos
resource "google_container_node_pool" "node_pool" {
  provider = google

  project = var.gcp_project_id

  # The location (region or zone) in which the cluster resides
  location = google_container_cluster.cluster.location

  count = length(var.node_pools)

  # The name of the node pool. Instance groups created will have the cluster
  # name prefixed automatically.
  #  name = format("%s-np", lookup(var.node_pools[count.index], "name", format("%03d", count.index + 1)))
  name = "${var.gcp_project_id}-npl-${var.cluster_name}-${lookup(var.node_pools[count.index], "name", format("%03d", count.index + 1))}"

  # The cluster to create the node pool for.
  cluster = google_container_cluster.cluster.name

  initial_node_count = lookup(var.node_pools[count.index], "initial_node_count", 1)

  # Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.
  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = lookup(var.node_pools[count.index], "autoscaling_min_node_count", 2)

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = lookup(var.node_pools[count.index], "autoscaling_max_node_count", 3)
  }

  # Target a specific Kubernetes version.
  version = lookup(var.node_pools[count.index], "version", "")

  # Node management configuration, wherein auto-repair and auto-upgrade is configured.
  management {
    # Whether the nodes will be automatically repaired.
    auto_repair = lookup(var.node_pools[count.index], "auto_repair", true)

    # Whether the nodes will be automatically upgraded.
    auto_upgrade = lookup(var.node_pools[count.index], "version", "") == "" ? lookup(var.node_pools[count.index], "auto_upgrade", true) : true
  }

  # Parameters used in creating the cluster's nodes.
  node_config {
    labels = merge(var.node_pool_additional_labels, lookup(var.node_pool_additional_labels_i, var.node_pools[count.index].name, {}), tomap(var.labels))
    # The image rype of a Google Compute Engine.
    image_type = lookup(
      var.node_pools[count.index],
      "image_type",
      "COS_CONTAINERD"
    )

    # The name of a Google Compute Engine machine type. Defaults to
    # n1-standard-1.
    machine_type = lookup(
      var.node_pools[count.index],
      "node_config_machine_type",
      "n1-standard-1",
    )

    service_account = google_service_account.default.email

    # Size of the disk attached to each node, specified in GB. The smallest
    # allowed disk size is 10GB. Defaults to 100GB.
    disk_size_gb = lookup(
      var.node_pools[count.index],
      "node_config_disk_size_gb",
      100
    )

    # Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd').
    # If unspecified, the default disk type is 'pd-standard'
    disk_type = lookup(
      var.node_pools[count.index],
      "node_config_disk_type",
      "pd-standard",
    )

    # A boolean that represents whether or not the underlying node VMs are
    # preemptible. See the official documentation for more information.
    # Defaults to false.
    preemptible = lookup(
      var.node_pools[count.index],
      "node_config_preemptible",
      true,
    )

    # The set of Google API scopes to be made available on all of the node VMs
    # under the "default" service account. These can be either FQDNs, or scope
    # aliases. The cloud-platform access scope authorizes access to all Cloud
    # Platform services, and then limit the access by granting IAM roles
    # https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # The metadata key/value pairs assigned to instances in the cluster.
    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }
  }

  # Change how long update operations on the node pool are allowed to take
  # before being considered to have failed. The default is 10 mins.
  # https://www.terraform.io/docs/configuration/resources.html#operation-timeouts
  timeouts {
    update = "20m"
  }
}