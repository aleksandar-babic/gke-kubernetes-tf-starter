locals {
  gke_cluster_name = "${local.global_resource_prefix}-core"
}

module "kubernetes-engine" {
  source  = "registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "18.0.0"

  project_id = var.provider_project_id
  zones      = data.google_compute_zones.available.names
  region     = var.provider_region
  name       = local.gke_cluster_name

  regional                          = true
  network                           = module.network.network_name
  subnetwork                        = local.gke_subnet_name
  ip_range_pods                     = local.gke_pods
  ip_range_services                 = local.gke_services
  add_cluster_firewall_rules        = true
  add_master_webhook_firewall_rules = true
  add_shadow_firewall_rules         = true
  enable_private_endpoint           = true
  create_service_account            = true
  enable_shielded_nodes             = true
  horizontal_pod_autoscaling        = true
  enable_vertical_pod_autoscaling   = false
  grant_registry_access             = true
  remove_default_node_pool          = true

  cluster_resource_labels = {
    application = var.app-bu
    environment = var.env
  }

  node_pools_labels = {
    all = {
      application = var.app-bu
      environment = var.env
      gke_node    = true
      gke_cluster = local.gke_cluster_name
    }
  }

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_pools_tags = {
    all = ["${local.gke_cluster_name}-node"]
  }

  initial_node_count     = var.gke_initial_node_count
  kubernetes_version     = var.gke_kubernetes_version
  maintenance_start_time = var.gke_maintenance_start_time
  cluster_autoscaling    = var.gke_cluster_autoscaling
  node_pools             = var.gke_node_pools

  master_authorized_networks = concat(
    [
      {
        cidr_block   = var.subnet_cidrs.gke
        display_name = local.gke_subnet_name
      }
    ],
    var.gke_additional_master_authorized_networks,
  )

  depends_on = [
    module.network.subnets
  ]
}
