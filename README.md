# gke-kubernetes-tf-starter

[![Main workflow action](https://github.com/aleksandar-babic/gke-kubernetes-tf-starter/actions/workflows/workflow.yaml/badge.svg)](https://github.com/aleksandar-babic/gke-kubernetes-tf-starter/actions/workflows/workflow.yaml)

Terraform module to provision battle-tested, batteries-included and secure GCP GKE Cluster with nginx-ingress and fully
automated DNS (external-dns) + TLS/SSL management (cert-manager + Letsencrypt).

The module deploys following resources:

* Custom VPC Network with:
    * GKE subnet (including pods and services secondary ranges)
    * CloudNat [optional]
* OpenVPN Server [optional]
    * With built-in user management (more details below) controllable through variables
* Cloud DNS zones
    * Controlled dynamically through variables
* GKE Standard cluster with:
    * Optional `regional` or `zonal` cluster modes
    * Optional `private` cluster type
    * Dynamic node pools controlled through the variables
    * Dynamic cluster autoscaler configuration
    * HPA enabled
    * VPA disabled
    * Removed default node pools
    * Master Authorized Networks - GKE subnet by default, optional additional configurable through variable
* [Helm charts](./modules/helm-charts) deployed in the cluster [optional]:
    * [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) external [optional]
    * [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) internal [optional]
    * [cert-manager](https://cert-manager.io/) configured with Letsencrypt prod ACME ClusterIssuer through DNS01 solver
    * [external-dns](https://github.com/kubernetes-sigs/external-dns) with Cloud DNS

## Provisioning

The module is using GCP Storage Bucket as state backend.

It is recommended to use [`tfenv`](https://github.com/tfutils/tfenv) and setup appropriate Terraform version defined
in `.terraform-version` file in each environment modules.

Additionally, [`gcloud`](https://cloud.google.com/sdk/gcloud/) with appropriate permissions to project is required in
order to provision any resources.

### Development

#### Local

The following tools have to be installed in order to run [pre-commit](https://pre-commit.com/) successfully:

* [checkov](https://github.com/bridgecrewio/checkov)
* [tfsec](https://aquasecurity.github.io/tfsec/v1.1.5/)
* [tflint](https://github.com/terraform-linters/tflint)
* [terraform-docs](https://terraform-docs.io/)

Setup of the git hooks can be done with `pre-commit install`. To force pre-commit checks on all files
run `pre-commit run -a`.

#### Github Actions

This module is using Github Actions to run `pre-commit` on `push` and `pull-request` events. The workflows can be
found [here](.github/workflows).

### Deployment

The following steps are required to deploy:

```shell
terraform init -backend-config="bucket=<state_storage_bucket_name>"

terraform apply
```

The module sets common values for the variables in `terraform.auto.tfvars`, additional variable overrides might be
required, examples shown below:

#### Private cluster

```terraform
# Variables needed for deployment of the private cluster
provider_project_id    = "<gcp_project_id>"
cloud_dns_zone_domains = [
  "<domain_name1>"
]

helm_cert_manager_issuer_email = "<issuer_email>"

openvpn_users = ["<vpn_username1>"]
```

> If the host that runs terraform apply does not have direct access to the VPC,
> it is recommended to initially also set `helm_deploy_enabled` to `false`, as private cluster is only reachable through
> VPC or VPN connection and helm deployments will time out. After the deployment runs successfully, connect the host to
> the VPC/VPN and run apply again with `helm_deploy_enabled` set to `true`.

#### Public cluster

```terraform
# Variables needed for deployment of the public cluster
provider_project_id    = "<gcp_project_id>"
cloud_dns_zone_domains = [
  "<domain_name1>"
]

helm_cert_manager_issuer_email = "<issuer_email>"

openvpn_users = ["<vpn_username1>"]

gke_additional_master_authorized_networks = [
  {
    cidr_block   = "<trusted_cidr>"
    display_name = "<user_friendly_name>"
  }
]
gke_private_cluster_enabled               = false
```

> It is required to add the CIDR of the host that runs terraform apply to the
> `gke_additional_master_authorized_networks` array in order to be able to deploy the helm charts (if enabled).

## OpenVPN

This module can optionally also deploy the OpenVPN server that can be used to access any VPC internal resources.

VPN users are managed directly in Terraform through the variable `openvpn_users` which is a list of strings where each
string represents the username of the user.

After successful Terraform apply, OpenVPN config files can be found in local directory `openvpn`.

Actual private key used for the OpenVPN is stored in Terraform state, and it is possible to retrieve all user profiles
at any time simply by running Terraform apply command.

By default, all the client traffic is routed through the VPN server.

> Output directory `openvpn` is in `.gitignore` so sensitive data such as private keys do not end up versioned in the git repository.

## Ingress, DNS and SSL/TLS

Default ingress controller is `nginx-ingress`, if no explicit annotations are set, this is the ingress controller that
will be used. Alternatively, it is possible to use built-in GCE ingress with the following
annotation `kubernetes.io/ingress.class: "gce"` set to Ingress resource.

For the domains specified in `var.cloud_dns_zone_domains` appropriate Cloud DNS zones will be
created. [`external-dns`](https://github.com/kubernetes-sigs/external-dns) is configured to automagically create DNS
records.

SSL/TLS Certificate management is handled by [`cert-manager`](https://cert-manager.io/) through Letsencrypt ACME cluster
issuer.

All the above allows seamless ingress setup that automatically handles path based routing, SSL/TLS certificates,
CloudDNS external DNS record management.

### Public (External) Ingress examples

Example Ingress manifest utilizing all 3 components:

#### Nginx Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-a
  annotations:
    external-dns.alpha.kubernetes.io/hostname: service-a.example.com.
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  rules:
    - host: service-a.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginxsvc
                port:
                  number: 80
  tls:
    - hosts:
        - service-a.example.com
      secretName: service-a-example-com
```

> Above manifest will expose service `nginxsvc` on `service-a.example.com` with HTTPS.

#### GCE (GCP native) Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-b
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "<global_static_ip_name>"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    external-dns.alpha.kubernetes.io/hostname: "service-b.example.com."
spec:
  rules:
    - host: service-b.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginxsvc
                port:
                  number: 80
  tls:
    - hosts:
        - service-b.example.com
      secretName: service-b-example-com
```

> **<global_static_ip_name>** needs to be replaced with the actual name of the global static ip reserved!**

> Above manifest will expose service `nginxsvc` on `service-b.example.com` with HTTPS.

### Private (Internal) Ingress examples

#### Nginx Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-c-internal
  annotations:
    external-dns.alpha.kubernetes.io/hostname: service-c.internal.example.com.
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx-internal
  rules:
    - host: service-c.internal.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginxsvc
                port:
                  number: 8080
  tls:
    - hosts:
        - service-c.internal.example.com
      secretName: service-c-internal-example-com
```

> Above manifest will expose service `nginxsvc` on `service-c.example.com` with HTTPS internally.

#### GCE (GCP native) Internal Ingress Controller

Using `gcp-internal` ingress is possible, but requires additional setup such as proxy-only subnets. More details in
the [official documentation](https://cloud.google.com/load-balancing/docs/l7-internal).

> For most use-cases using `nginx-internal` ingress is much simpler solution.

## Module details

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
| <a name="input_gke_node_pools"></a> [gke\_node\_pools](#input\_gke\_node\_pools) | Node pools to be created for the GKE cluster. | <pre>list(object({<br>    name                        = string<br>    machine_type                = string<br>    preemptible                 = bool<br>    disk_type                   = string<br>    disk_size_gb                = number<br>    autoscaling                 = bool<br>    auto_repair                 = bool<br>    sandbox_enabled             = bool<br>    cpu_manager_policy          = string<br>    cpu_cfs_quota               = bool<br>    enable_integrity_monitoring = bool<br>    enable_secure_boot          = bool<br>    image_type                  = string<br>  }))</pre> | n/a | yes |
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
