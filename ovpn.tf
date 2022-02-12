resource "google_compute_firewall" "openvpn" {
  count = length(var.openvpn_users) != 0 ? 1 : 0

  name    = "${local.global_resource_prefix}-internet-openvpn-udp-1194-allow-rule"
  network = module.network.network_name

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn"]
}

module "openvpn" {
  count = length(var.openvpn_users) != 0 ? 1 : 0

  source  = "registry.terraform.io/DeimosCloud/openvpn/google"
  version = "1.2.4"

  prefix                 = local.global_resource_prefix
  project_id             = var.provider_project_id
  region                 = var.provider_region
  zone                   = data.google_compute_zones.available.names[0]
  network                = module.network.network_name
  subnetwork             = local.gke_subnet_name
  network_tier           = "PREMIUM"
  users                  = var.openvpn_users
  machine_type           = "f1-micro"
  disk_size_gb           = "20"
  route_only_private_ips = false
  tags                   = ["openvpn"]

  depends_on = [module.network.subnets]
}
