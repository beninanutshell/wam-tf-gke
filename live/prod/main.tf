module "gke-cluster" {
  source = "../../modules/gke-cluster/"

  project_id        = "wam-shared-bootstrap-797e"
  name              = "wam-kube-production"
  location          = "europe-west1"
  update_start_time = "2020-05-21T22:00:00.00Z"
  update_end_time   = "2020-05-22T02:00:00.00Z"
  update_recurrence = "FREQ=DAILY"
  maintenance_exclusion = {
    new-year = {
      exclusion_update_name       = "new-year"
      exclusion_update_start_time = "2021-12-31T22:00:00.00Z"
      exclusion_update_end_time   = "2022-01-20T22:00:00.00Z"
    },
  }
  enable_cluster_autoscaling = true
  min_cpu_platform           = "Intel Cascade Lake"
  cluster_network_policy     = false
  autoscaling_resource_limits = {
    cpu = {
      resource_type = "cpu"
      minimum       = 2
      maximum       = 8
    },
    memory = {
      resource_type = "memory"
      minimum       = 8
      maximum       = 32
    }
  }
  master_ipv4_cidr_block        = "172.16.0.0/28"
  network                       = "projects/wam-shared-bootstrap-797e/global/networks/wam-bootstrap-vpc"
  subnetwork                    = "projects/wam-shared-bootstrap-797e/regions/europe-west1/subnetworks/wam-bootstrap-subnet-gke"
  cluster_secondary_range_name  = "wam-bootstrap-vpc-sir-pods-gke"
  services_secondary_range_name = "wam-bootstrap-vpc-sir-svc-gke"
  authorized_cidr_blocks_list = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "open-world"
    },
  ]
  domain_cloud_identity = "beninanutshell.com"
  labels = {
    cluster-name = "wam-recherche-development"
    region       = "europe-west1"
  }
  cluster_telemetry_is_set = true
  service_account          = "wam-sac-gke-demo@wam-shared-bootstrap-797e.iam.gserviceaccount.com"
  disable_istio_config     = false
}

module "gke-node-pool" {
  depends_on = [module.gke-cluster, ]
  source     = "../../modules/gke-node-pool/"

  project_id = "wam-shared-bootstrap-797e"
  region     = "europe-west1"
  map_node_pools = {
    general-purpose = {
      cluster                = "wam-kube-production"
      name                   = "general"
      machine_type           = "n1-standard-2"
      location               = "europe-west1"
      autoscaling            = true
      service_account        = "wam-sac-gke-demo@wam-shared-bootstrap-797e.iam.gserviceaccount.com"
      enable_cluster_sandbox = false
      enable_taint           = false
      labels = {
        clusterName  = "gke-test"
        region       = "europe-west1"
        workloadType = "general-purpose"
      }
    },
  }
}