output "vpc_network_self_link" {
  description = "Self-link of the created network."
  value       = module.network.network_self_link
}

output "vpc_subnet_self_links" {
  description = "Self-links of the created network subnets."
  value       = module.network.subnets_self_links
}

output "gke_cluster_name" {
  description = "Name of the created GKE cluster."
  value       = module.kubernetes-engine.name
}
