variable "project_id" {
  type        = string
  description = "GCP Project Id."
}

variable "cert_manager_issuer_email" {
  type        = string
  description = "Email to be configured for Letsencrypt ACME notifications."
}

variable "global_resource_prefix" {
  type        = string
  description = "Prefix to apply to resource names."
}

variable "external_nginx_ingress_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable or disable deployment of the nginx-ingress external ingress controller."
}

variable "internal_nginx_ingress_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable or disable deployment of the nginx-ingress internal ingress controller."
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork to use for the resources."
}
