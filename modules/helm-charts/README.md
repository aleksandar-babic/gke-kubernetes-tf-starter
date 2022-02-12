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
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.4.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ingress_external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.ingress_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_issuer_email"></a> [cert\_manager\_issuer\_email](#input\_cert\_manager\_issuer\_email) | Email to be configured for Letsencrypt ACME notifications. | `string` | n/a | yes |
| <a name="input_external_nginx_ingress_enabled"></a> [external\_nginx\_ingress\_enabled](#input\_external\_nginx\_ingress\_enabled) | Flag to enable or disable deployment of the nginx-ingress external ingress controller. | `bool` | `true` | no |
| <a name="input_global_resource_prefix"></a> [global\_resource\_prefix](#input\_global\_resource\_prefix) | Prefix to apply to resource names. | `string` | n/a | yes |
| <a name="input_internal_nginx_ingress_enabled"></a> [internal\_nginx\_ingress\_enabled](#input\_internal\_nginx\_ingress\_enabled) | Flag to enable or disable deployment of the nginx-ingress internal ingress controller. | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project Id. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Subnetwork to use for the resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
