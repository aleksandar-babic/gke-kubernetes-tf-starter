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
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.4.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.13.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes-engine"></a> [kubernetes-engine](#module\_kubernetes-engine) | registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster | 18.0.0 |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/terraform-google-modules/network/google | 4.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ingress_external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.ingress_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_dns_managed_zone.domains](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_project_iam_member.cert_manager_dns_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.external_dns_dns_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.cert_manager_dns_solver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.external_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.cert_manager_dns_solver_workload_identity_cert_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_binding.external_dns_workload_identity_external_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [helm_release.nginx_ingress_external](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [helm_release.nginx_ingress_internal](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [kubectl_manifest.letsencrypt_cluster_issuer_dns](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.1/docs/resources/manifest) | resource |
| [kubernetes_cluster_role_binding.admin](https://registry.terraform.io/providers/hashicorp/kubernetes/2.7.1/docs/resources/cluster_role_binding) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app-bu"></a> [app-bu](#input\_app-bu) | Identifier of the owner (either an Application or Business Unit) | `string` | `"ops"` | no |
| <a name="input_cert_manager_issuer_email"></a> [cert\_manager\_issuer\_email](#input\_cert\_manager\_issuer\_email) | Email to be configured for Letsencrypt ACME notifications. | `string` | n/a | yes |
| <a name="input_cloud_dns_zone_domains"></a> [cloud\_dns\_zone\_domains](#input\_cloud\_dns\_zone\_domains) | List of the domains that should have Cloud DNS zones created. | `list(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier for the resources. | `string` | `"dev"` | no |
| <a name="input_gke_additional_master_authorized_networks"></a> [gke\_additional\_master\_authorized\_networks](#input\_gke\_additional\_master\_authorized\_networks) | List of the additional Master Authorized Networks for the GKE cluster. | <pre>list(object({<br>    cidr_block   = string<br>    display_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_gke_cluster_admins"></a> [gke\_cluster\_admins](#input\_gke\_cluster\_admins) | List of users that will have cluster-admin role binding created. | `list(string)` | `[]` | no |
| <a name="input_gke_cluster_autoscaling"></a> [gke\_cluster\_autoscaling](#input\_gke\_cluster\_autoscaling) | Cluster autoscaling configuration. | <pre>object({<br>    enabled       = bool<br>    min_cpu_cores = number<br>    max_cpu_cores = number<br>    min_memory_gb = number<br>    max_memory_gb = number<br>    gpu_resources = list(object({ resource_type = string, minimum = number, maximum = number }))<br>  })</pre> | n/a | yes |
| <a name="input_gke_initial_node_count"></a> [gke\_initial\_node\_count](#input\_gke\_initial\_node\_count) | Number of the cluster nodes deployed initially. | `number` | `3` | no |
| <a name="input_gke_kubernetes_version"></a> [gke\_kubernetes\_version](#input\_gke\_kubernetes\_version) | Version of the Kubernetes to run on GKE cluster. | `string` | `"latest"` | no |
| <a name="input_gke_maintenance_start_time"></a> [gke\_maintenance\_start\_time](#input\_gke\_maintenance\_start\_time) | UTC time for the maintenance window of the GKE cluster. | `string` | `"04:00"` | no |
| <a name="input_gke_node_pools"></a> [gke\_node\_pools](#input\_gke\_node\_pools) | Node pools to be created for the GKE cluster. | <pre>list(object({<br>    name                        = string<br>    machine_type                = string<br>    preemptible                 = bool<br>    disk_type                   = string<br>    disk_size_gb                = number<br>    autoscaling                 = bool<br>    auto_repair                 = bool<br>    sandbox_enabled             = bool<br>    cpu_manager_policy          = string<br>    cpu_cfs_quota               = bool<br>    enable_integrity_monitoring = bool<br>    enable_secure_boot          = bool<br>  }))</pre> | n/a | yes |
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
