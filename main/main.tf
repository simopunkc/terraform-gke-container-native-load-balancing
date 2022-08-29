resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 5.2.0"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                    = "~> 23.0.0"
  depends_on                 = [module.gcp-network]
  project_id                 = var.project_id
  name                       = "${var.cluster_name}-${var.env_name}"
  region                     = var.region
  regional                   = true
  network                    = module.gcp-network.network_name
  subnetwork                 = module.gcp-network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  node_pools = [
    {
      name         = "node-pool"
      machine_type = "e2-micro"
      #   node_locations           = "asia-southeast1-a,asia-southeast1-b,asia-southeast1-c"
      node_locations           = "asia-southeast1-b"
      min_count                = 1
      max_count                = 2
      disk_size_gb             = 30
      local_ssd_count          = 0
      disk_type                = "pd-standard"
      image_type               = "COS_CONTAINERD"
      auto_repair              = true
      auto_upgrade             = true
      spot                     = false
      enable_gcfs              = false
      enable_gvnic             = false
      remove_default_node_pool = true
      initial_node_count       = 1
      preemptible              = false
    },
  ]
}
module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}
