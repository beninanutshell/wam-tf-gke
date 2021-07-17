/***************************************************
  Google Node Pool variables
****************************************************/

variable "project_id" {
  type        = string
  description = "The project ID. Changing this forces a new project to be created."
}

variable "region" {
  type        = string
  description = "The location to list versions for."
}

variable "map_node_pools" {
  type = map(object({
    cluster                = string
    name                   = string
    location               = string
    autoscaling            = bool
    min_count              = optional(number)
    max_count              = optional(number)
    initial_node_count     = optional(number)
    node_count             = optional(number)
    disk_size_gb           = optional(number)
    disk_type              = optional(string)
    boot_disk_kms_key      = optional(string)
    image_type             = optional(string)
    labels                 = optional(map(string))
    local_ssd_count        = optional(number)
    machine_type           = optional(string)
    min_cpu_platform       = optional(string)
    preemptible            = optional(bool)
    service_account        = optional(string)
    tags                   = optional(list(string))
    enable_cluster_sandbox = bool
    node_metadata          = optional(string)
    enable_taint           = optional(bool)
    taint_key              = optional(string)
    taint_value            = optional(string)
    taint_effect           = optional(string)
    gpu_type               = optional(string)
    gpu_count              = optional(number)
    max_pods_per_node      = optional(number)
    max_surge              = optional(number)
    max_unavailable        = optional(number)
    auto_repair            = optional(bool)
    auto_upgrade           = optional(bool)
  }))
  description = "The map of created node-pool."
}