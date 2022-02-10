locals {
  gke_subnet_name = "${local.global_resource_prefix}-gke-${var.provider_region}-subnet"
  gke_pods        = "${local.gke_subnet_name}-pods"
  gke_services    = "${local.gke_subnet_name}-services"
  db_subnet_name  = "${local.global_resource_prefix}-db-${var.provider_region}-subnet"
}

module "network" {
  source  = "registry.terraform.io/terraform-google-modules/network/google"
  version = "4.0.1"

  network_name                           = "${local.global_resource_prefix}-vpc"
  project_id                             = var.provider_project_id
  auto_create_subnetworks                = false
  delete_default_internet_gateway_routes = false
  mtu                                    = 1460

  subnets = [
    {
      subnet_name           = local.gke_subnet_name
      subnet_ip             = var.subnet_cidrs.gke
      subnet_region         = var.provider_region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    }
  ]

  secondary_ranges = {
    (local.gke_subnet_name) = [
      {
        range_name    = local.gke_pods
        ip_cidr_range = var.subnet_cidrs.gke_pods
      },
      {
        range_name    = local.gke_services
        ip_cidr_range = var.subnet_cidrs.gke_services
      }
    ]
  }

  firewall_rules = [
    {
      name        = "${local.global_resource_prefix}-internal-internal-all-all-allow-rule"
      description = "Allow internal inter-subnet communication."
      direction   = "INGRESS"
      ranges = [
        var.subnet_cidrs.gke,
        var.subnet_cidrs.gke_services,
        var.subnet_cidrs.gke_pods,
      ]
      priority = 65534
      allow = [
        {
          protocol = "tcp",
          ports    = ["0-65535"]
        },
        {
          protocol = "udp",
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp",
          ports    = []
        },
      ]
    }
  ]
}
