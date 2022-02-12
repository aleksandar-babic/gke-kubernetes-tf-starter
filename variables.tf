variable "provider_region" {
  type        = string
  description = "Region to be used within the GCP provider."
  default     = "europe-west3"
}

variable "provider_project_id" {
  type        = string
  description = "Project to be used within the GCP Provider."
}

variable "env" {
  type        = string
  description = "Environment identifier for the resources."
  default     = "dev"
}

variable "prefix" {
  type        = string
  description = "Prefix to add to the resources."
  default     = "starter"
}

variable "app-bu" {
  type        = string
  description = "Identifier of the owner (either an Application or Business Unit)"
  default     = "ops"
}

variable "subnet_cidrs" {
  type = object({
    gke          = string
    gke_services = string
    gke_pods     = string
  })
  description = "Object with mappings for the subnet CIDRs based on the context."
}

variable "gke_initial_node_count" {
  type        = number
  description = "Number of the cluster nodes deployed initially."
  default     = 3
}

variable "gke_kubernetes_version" {
  type        = string
  description = "Version of the Kubernetes to run on GKE cluster."
  default     = "latest"
}

variable "gke_maintenance_start_time" {
  type        = string
  description = "UTC time for the maintenance window of the GKE cluster."
  default     = "04:00"
}

variable "gke_cluster_autoscaling" {
  type = object({
    enabled       = bool
    min_cpu_cores = number
    max_cpu_cores = number
    min_memory_gb = number
    max_memory_gb = number
    gpu_resources = list(object({ resource_type = string, minimum = number, maximum = number }))
  })
  description = "Cluster autoscaling configuration."
}

variable "gke_node_pools" {
  type = list(object({
    name                        = string
    machine_type                = string
    preemptible                 = bool
    disk_type                   = string
    disk_size_gb                = number
    autoscaling                 = bool
    auto_repair                 = bool
    sandbox_enabled             = bool
    cpu_manager_policy          = string
    cpu_cfs_quota               = bool
    enable_integrity_monitoring = bool
    enable_secure_boot          = bool
  }))
  description = "Node pools to be created for the GKE cluster."
}

variable "gke_additional_master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "List of the additional Master Authorized Networks for the GKE cluster."
  default     = []
}

variable "gke_cluster_admins" {
  type        = list(string)
  description = "List of users that will have cluster-admin role binding created."
  default     = []
}

variable "gke_regional_cluster_enabled" {
  type        = bool
  description = "Flag to either enable regional (true) or zonal (false) mode for cluster."
  default     = false
}

variable "gke_private_cluster_enabled" {
  type        = bool
  description = "Flag to either enable private endpoint and nodes, or use regular public endpoint and nodes with public ips."
  default     = true
}

variable "cloud_dns_zone_domains" {
  type        = list(string)
  description = "List of the domains that should have Cloud DNS zones created."
}

variable "openvpn_users" {
  type        = list(string)
  description = "List of the OpenVPN users to be created. (if list is empty, OpenVPN instance will not be created)"
  default     = []
}

variable "helm_deploy_enabled" {
  type        = bool
  description = "Flag to enable or disable deployment of the helm-charts module into the cluster."
  default     = true
}

variable "helm_cert_manager_issuer_email" {
  type        = string
  description = "Email to be configured for Letsencrypt ACME notifications. (ignored with helm_deploy_enabled false)"
}

variable "helm_external_nginx_ingress_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable or disable deployment of the nginx-ingress external ingress controller. (ignored with helm_deploy_enabled false)"
}

variable "helm_internal_nginx_ingress_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable or disable deployment of the nginx-ingress internal ingress controller. (ignored with helm_deploy_enabled false)"
}

variable "cloudnat_enabled" {
  type        = bool
  description = "Flag to enable or disable deployment of the CloudNat. (required with private cluster)"
  default     = true
}
