/******************************************
  Google container cluster variables
*****************************************/

variable "project_id" {
  type        = string
  description = "The project ID. Changing this forces a new project to be created."
}

variable "name" {
  type        = string
  description = "The name of the cluster, unique within the project and location."
}

variable "description" {
  type        = string
  description = "Description of the cluster."
  default     = ""
}

variable "location" {
  type        = string
  description = "The location (region or zone) in which the cluster master will be created, as well as the default node location."
}

variable "node_locations" {
  type        = list(string)
  description = "The list of zones in which the cluster's nodes are located."
  default     = []
}

variable "channel" {
  type        = string
  description = "The selected release channel."
  default     = "REGULAR"

  validation {
    condition     = contains(["UNSPECIFIED", "RAPID", "REGULAR", "STABLE"], var.channel)
    error_message = "The accepted values are: 'UNSPECIFIED', 'RAPID', 'REGULAR', 'STABLE'. Defaults to 'REGULAR'."
  }
}

variable "update_start_time" {
  type        = string
  description = "In RFC3339 format 'HH:MM', where HH : [00-23] and MM : [00-59] GMT."
}

variable "update_end_time" {
  type        = string
  description = "In RFC3339 format 'HH:MM', where HH : [00-23] and MM : [00-59] GMT."
}

variable "update_recurrence" {
  type        = string
  description = "Specify recurrence in RFC5545 RRULE format, to specify when this recurs. Note that GKE may accept other formats, but will return values in UTC, causing a permanent diff."
}

variable "maintenance_exclusion" {
  type = map(object({
    exclusion_update_name       = string
    exclusion_update_start_time = string
    exclusion_update_end_time   = string
  }))
  description = "Map of maintenance exclusions. A cluster can have up to three."
  default     = {}
}
/*
variable "notification_config_topic" {
  type        = string
  description = "Configuration for the cluster upgrade notifications feature.Specify the pub/sub topic."
}
*/
variable "enable_vertical_pod_autoscaling" {
  type        = bool
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it."
  default     = true
}

variable "enable_cluster_autoscaling" {
  type        = bool
  description = "Whether node auto-provisioning is enabled. Resource limits for cpu and memory must be defined to enable node auto-provisioning."
}

variable "min_cpu_platform" {
  type        = string
  description = "Minimum CPU platform to be used for NAP created node pools. The instance may be scheduled on the specified or newer CPU platform."
}

variable "autoscaling_profile" {
  type        = string
  description = "Let you choose whether the cluster autoscaler should optimize for resource utilization or resource availability when deciding to remove nodes from a cluster."
  default     = "OPTIMIZE_UTILIZATION"

  validation {
    condition     = contains(["BALANCED", "OPTIMIZE_UTILIZATION"], var.autoscaling_profile)
    error_message = "The autoscaling_profile variable must only be one of 'BALANCED' or 'OPTIMIZE_UTILIZATION'.Defaults to OPTIMIZE_UTILIZATION."
  }

}

variable "autoscaling_resource_limits" {
  type = map(object({
    resource_type = string
    minimum       = number
    maximum       = number
  }))
  description = "Global constraints for machine resources in the cluster. Configuring the cpu and memory types is required if node auto-provisioning is enabled. These limits will apply to node pool autoscaling in addition to node auto-provisioning."
  default     = {}
}

variable "enable_private_endpoint" {
  type        = bool
  description = "When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true."
  default     = false
}

variable "enable_private_nodes" {
  type        = bool
  description = "Enables the private cluster feature, creating a private endpoint on the cluster. In a private cluster, nodes only have RFC 1918 private addresses and communicate with the master's private endpoint via private networking."
  default     = true
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet."
}

variable "enable_master_global_access_config" {
  type        = bool
  description = "Controls cluster master global access settings. If unset, Terraform will no longer manage this field and will not modify the previously-set value."
  default     = false
}

variable "disable_default_snat" {
  type        = bool
  description = " GKE SNAT DefaultSnatStatus contains the desired state of whether default sNAT should be disabled on the cluster."
  default     = false
}

variable "network" {
  type        = string
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
}

variable "subnetwork" {
  type        = string
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
}

variable "cluster_secondary_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for POD IP addresses."
}

variable "services_secondary_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for SERVICE ClusterIPs."
}

variable "default_max_pods_per_node" {
  type        = string
  description = "The default maximum number of pods per node in this cluster."
  default     = "110"
}

variable "enable_intranode_visibility" {
  type        = bool
  description = "Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network."
  default     = true
}

variable "enable_l4_ilb_subsetting" {
  type        = bool
  description = "Whether L4ILB Subsetting is enabled for this cluster."
  default     = false
}

variable "authorized_cidr_blocks_list" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "External networks that can access the Kubernetes cluster master through HTTPS."
}

variable "cluster_network_policy" {
  type        = bool
  description = "Configuration options for the NetworkPolicy based on CALICO CNI implementation."
  default     = false
}
/*
variable "key_name" {
  type        = string
  description = "The key to use to encrypt/decrypt secrets."
}
*/
variable "domain_cloud_identity" {
  type        = string
  description = "The domain of the organization used for the RBAC Group."
}

variable "labels" {
  type        = map(string)
  description = "The Kubernetes labels (key/value pairs) to be applied to each node.The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified."
}

variable "cluster_telemetry_is_set" {
  type        = bool
  description = "Configuration for ClusterTelemetry feature"
}

variable "monitoring_service" {
  type        = string
  description = "The monitoring service that the cluster should write metrics to."
  default     = "none"
}

variable "logging_service" {
  type        = string
  description = "The logging service that the cluster should write logs to."
  default     = "none"
}

variable "enable_tpu" {
  type        = bool
  description = "Whether to enable Cloud TPU resources in this cluster."
  default     = false
}

variable "enable_kubernetes_alpha" {
  type        = bool
  description = "Whether to enable Kubernetes Alpha features for this cluster. Note that when this option is enabled, the cluster cannot be upgraded and will be automatically deleted after 30 days."
  default     = false
}

variable "enable_binary_authorization" {
  type        = bool
  description = "Enable Binary Authorization for this cluster. If enabled, all container images will be validated by Google Binary Authorization."
  default     = false
}

variable "enable_network_egress_metering" {
  type        = bool
  description = "Whether to enable network egress metering for this cluster. If enabled, a daemonset will be created in the cluster to meter network egress traffic."
  default     = true
}

variable "enable_resource_consumption_metering" {
  type        = bool
  description = "Whether to enable resource consumption metering on this cluster. When enabled, a table will be created in the resource export BigQuery dataset to store resource consumption data."
  default     = true
}
/*
variable "dataset_id" {
  type        = string
  description = "The ID of a BigQuery Dataset."
}
*/
variable "cluster_telemetry_type" {
  type        = string
  description = "The chosen Cluster Telemetry setting. 'SYSTEM_ONLY' is for workloads running in system namespaces (kube-system, istio-system, etc.). 'ENABLE' is for all workloads, and 'DISABLE' disables all telemetry"
  default     = "ENABLED"

  validation {
    condition     = contains(["DISABLED", "SYSTEM_ONLY", "ENABLED"], var.cluster_telemetry_type)
    error_message = "The cluster_telemetry_type variable must only be one of 'SYSTEM_ONLY' OR 'ENABLE'."
  }
}

variable "disable_horizontal_pod_autoscaling" {
  type        = bool
  description = "The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods."
  default     = false
}

variable "disable_http_load_balancing" {
  type        = bool
  description = "The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster."
  default     = false
}

variable "disable_cloudrun_config" {
  type        = bool
  description = "The status of the CloudRun addon. It is disabled by default."
  default     = true
}

variable "disable_istio_config" {
  type        = bool
  description = "The status of the Istio addon, which makes it easy to set up Istio for services in a cluster. It is disabled by default."
  default     = true
}

variable "auth" {
  type        = string
  description = "he authentication type between services in Istio."
  default     = "AUTH_NONE"
}

variable "enable_dns_cache_config" {
  type        = bool
  description = "The status of the NodeLocal DNSCache addon. It is disabled by default."
  default     = true
}

variable "enable_gce_persistent_disk_csi_driver_config" {
  type        = bool
  description = "Whether this cluster should enable the Google Compute Engine Persistent Disk Container Storage Interface (CSI) Driver. "
  default     = true
}

variable "enable_kalm_config" {
  type        = bool
  description = "Configuration for the KALM addon, which manages the lifecycle of k8s."
  default     = false
}

variable "enable_config_connector_config" {
  type        = bool
  description = "The status of the ConfigConnector addon. It is disabled by default."
  default     = false
}

variable "service_account" {
  type        = string
  description = "The Google Cloud Platform Service Account to be used by the node VMs."
}