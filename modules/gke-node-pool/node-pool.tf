/***************************************************
  Google Node Pool
****************************************************/

resource "google_container_node_pool" "node_pool" {

  provider = google-beta
  for_each = var.map_node_pools

  project  = var.project_id
  cluster  = each.value.cluster
  name     = format("%s-pool", each.value.name)
  location = each.value.location
  dynamic "autoscaling" {
    for_each = coalesce(each.value.autoscaling, true) ? [each.value] : []
    content {
      min_node_count = coalesce(autoscaling.value.min_count, 1)
      max_node_count = coalesce(autoscaling.value.max_count, 10)
    }
  }

  initial_node_count = coalesce(each.value.autoscaling, true) ? coalesce(each.value.initial_node_count, coalesce(each.value.min_count, 1)) : null

  node_count = coalesce(each.value.autoscaling, true) ? null : coalesce(each.value.node_count, 1)

  #checkov:skip=CKV_GCP_22:OS by default now is cos_containerd
  node_config {
    disk_size_gb      = coalesce(each.value.disk_size_gb, 50)
    disk_type         = coalesce(each.value.disk_type, "pd-ssd")
    boot_disk_kms_key = each.value.boot_disk_kms_key
    image_type        = coalesce(each.value.image_type, "COS_CONTAINERD")
    labels            = each.value.labels
    local_ssd_count   = each.value.local_ssd_count
    machine_type      = coalesce(each.value.machine_type, "n2-standard-2")
    min_cpu_platform  = coalesce(each.value.min_cpu_platform, "Intel Cascade Lake")
    preemptible       = coalesce(each.value.preemptible, false)
    service_account   = each.value.service_account
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    tags              = coalesce(each.value.tags, [])

    dynamic "sandbox_config" {
      for_each = coalesce(each.value.enable_cluster_sandbox, true) ? [each.value] : []
      content {
        sandbox_type = "gvisor"
      }
    }

    #checkov:skip=CKV_GCP_72:Integrity Monitoring for Shielded GKE nodes
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    #checkov:skip=CKV_GCP_69:GKE Metadata Server is enabled
    workload_metadata_config {
      node_metadata = coalesce(each.value.node_metadata, "GKE_METADATA_SERVER")
    }

    dynamic "taint" {
      for_each = coalesce(each.value.enable_taint, true) ? [each.value] : []
      content {
        key    = taint.value.taint_key
        value  = taint.value.taint_value
        effect = taint.value.taint_effect
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    dynamic "guest_accelerator" {
      for_each = each.value.gpu_type != null ? [each.value] : []
      content {
        type  = guest_accelerator.value.gpu_type
        count = guest_accelerator.value.gpu_count
      }
    }
  }

  max_pods_per_node = coalesce(each.value.max_pods_per_node, 110)

  upgrade_settings {
    max_surge       = coalesce(each.value.max_surge, 1)
    max_unavailable = coalesce(each.value.max_unavailable, 0)
  }

  #checkov:skip=CKV_GCP_10: Automatic node upgrade is enabled by default
  #checkov:skip=CKV_GCP_9: Automatic node repair is enabled by default

  management {
    auto_repair  = coalesce(each.value.auto_repair, true)
    auto_upgrade = coalesce(each.value.auto_upgrade, true)
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }
}
