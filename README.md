# gke-kubernetes-tf-starter
Terraform module to provision battle-tested, batteries-included GCP GKE Cluster.

**README IN PROGRESS**

# Module details
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.5 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 3.90.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud-nat"></a> [cloud-nat](#module\_cloud-nat) | registry.terraform.io/terraform-google-modules/cloud-nat/google | ~> 2.0.0 |
| <a name="module_helm_charts"></a> [helm\_charts](#module\_helm\_charts) | ./modules/helm-charts | n/a |
| <a name="module_kubernetes-engine"></a> [kubernetes-engine](#module\_kubernetes-engine) | registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster | 18.0.0 |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/terraform-google-modules/network/google | 4.0.1 |
| <a name="module_openvpn"></a> [openvpn](#module\_openvpn) | registry.terraform.io/DeimosCloud/openvpn/google | 1.2.4 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.openvpn](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_dns_managed_zone.domains](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [kubernetes_cluster_role_binding.admin](https://registry.terraform.io/providers/hashicorp/kubernetes/2.7.1/docs/resources/cluster_role_binding) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app-bu"></a> [app-bu](#input\_app-bu) | Identifier of the owner (either an Application or Business Unit) | `string` | `"ops"` | no |
| <a name="input_cloud_dns_zone_domains"></a> [cloud\_dns\_zone\_domains](#input\_cloud\_dns\_zone\_domains) | List of the domains that should have Cloud DNS zones created. | `list(string)` | n/a | yes |
| <a name="input_cloudnat_enabled"></a> [cloudnat\_enabled](#input\_cloudnat\_enabled) | Flag to enable or disable deployment of the CloudNat. (required with private cluster) | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier for the resources. | `string` | `"dev"` | no |
| <a name="input_gke_additional_master_authorized_networks"></a> [gke\_additional\_master\_authorized\_networks](#input\_gke\_additional\_master\_authorized\_networks) | List of the additional Master Authorized Networks for the GKE cluster. | <pre>list(object({<br>    cidr_block   = string<br>    display_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_gke_cluster_admins"></a> [gke\_cluster\_admins](#input\_gke\_cluster\_admins) | List of users that will have cluster-admin role binding created. | `list(string)` | `[]` | no |
| <a name="input_gke_cluster_autoscaling"></a> [gke\_cluster\_autoscaling](#input\_gke\_cluster\_autoscaling) | Cluster autoscaling configuration. | <pre>object({<br>    enabled       = bool<br>    min_cpu_cores = number<br>    max_cpu_cores = number<br>    min_memory_gb = number<br>    max_memory_gb = number<br>    gpu_resources = list(object({ resource_type = string, minimum = number, maximum = number }))<br>  })</pre> | n/a | yes |
| <a name="input_gke_initial_node_count"></a> [gke\_initial\_node\_count](#input\_gke\_initial\_node\_count) | Number of the cluster nodes deployed initially. | `number` | `3` | no |
| <a name="input_gke_kubernetes_version"></a> [gke\_kubernetes\_version](#input\_gke\_kubernetes\_version) | Version of the Kubernetes to run on GKE cluster. | `string` | `"latest"` | no |
| <a name="input_gke_maintenance_start_time"></a> [gke\_maintenance\_start\_time](#input\_gke\_maintenance\_start\_time) | UTC time for the maintenance window of the GKE cluster. | `string` | `"04:00"` | no |
| <a name="input_gke_node_pools"></a> [gke\_node\_pools](#input\_gke\_node\_pools) | Node pools to be created for the GKE cluster. | <pre>list(object({<br>    name                        = string<br>    machine_type                = string<br>    preemptible                 = bool<br>    disk_type                   = string<br>    disk_size_gb                = number<br>    autoscaling                 = bool<br>    auto_repair                 = bool<br>    sandbox_enabled             = bool<br>    cpu_manager_policy          = string<br>    cpu_cfs_quota               = bool<br>    enable_integrity_monitoring = bool<br>    enable_secure_boot          = bool<br>  }))</pre> | n/a | yes |
| <a name="input_gke_private_cluster_enabled"></a> [gke\_private\_cluster\_enabled](#input\_gke\_private\_cluster\_enabled) | Flag to either enable private endpoint and nodes, or use regular public endpoint and nodes with public ips. | `bool` | `true` | no |
| <a name="input_gke_regional_cluster_enabled"></a> [gke\_regional\_cluster\_enabled](#input\_gke\_regional\_cluster\_enabled) | Flag to either enable regional (true) or zonal (false) mode for cluster. | `bool` | `false` | no |
| <a name="input_helm_cert_manager_issuer_email"></a> [helm\_cert\_manager\_issuer\_email](#input\_helm\_cert\_manager\_issuer\_email) | Email to be configured for Letsencrypt ACME notifications. (ignored with helm\_deploy\_enabled false) | `string` | n/a | yes |
| <a name="input_helm_deploy_enabled"></a> [helm\_deploy\_enabled](#input\_helm\_deploy\_enabled) | Flag to enable or disable deployment of the helm-charts module into the cluster. | `bool` | `true` | no |
| <a name="input_helm_external_nginx_ingress_enabled"></a> [helm\_external\_nginx\_ingress\_enabled](#input\_helm\_external\_nginx\_ingress\_enabled) | Flag to enable or disable deployment of the nginx-ingress external ingress controller. (ignored with helm\_deploy\_enabled false) | `bool` | `true` | no |
| <a name="input_helm_internal_nginx_ingress_enabled"></a> [helm\_internal\_nginx\_ingress\_enabled](#input\_helm\_internal\_nginx\_ingress\_enabled) | Flag to enable or disable deployment of the nginx-ingress internal ingress controller. (ignored with helm\_deploy\_enabled false) | `bool` | `true` | no |
| <a name="input_openvpn_users"></a> [openvpn\_users](#input\_openvpn\_users) | List of the OpenVPN users to be created. (if list is empty, OpenVPN instance will not be created) | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to the resources. | `string` | `"starter"` | no |
| <a name="input_provider_project_id"></a> [provider\_project\_id](#input\_provider\_project\_id) | Project to be used within the GCP Provider. | `string` | n/a | yes |
| <a name="input_provider_region"></a> [provider\_region](#input\_provider\_region) | Region to be used within the GCP provider. | `string` | `"europe-west3"` | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | Object with mappings for the subnet CIDRs based on the context. | <pre>object({<br>    gke          = string<br>    gke_services = string<br>    gke_pods     = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_cluster_name"></a> [gke\_cluster\_name](#output\_gke\_cluster\_name) | Name of the created GKE cluster. |
| <a name="output_vpc_network_self_link"></a> [vpc\_network\_self\_link](#output\_vpc\_network\_self\_link) | Self-link of the created network. |
| <a name="output_vpc_subnet_self_links"></a> [vpc\_subnet\_self\_links](#output\_vpc\_subnet\_self\_links) | Self-links of the created network subnets. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
