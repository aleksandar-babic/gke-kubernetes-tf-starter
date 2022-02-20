locals {
  global_resource_prefix = "${var.prefix}-${var.env}-${var.app-bu}"
}

module "helm_charts" {
  count = var.helm_deploy_enabled ? 1 : 0

  source = "./modules/helm-charts"

  project_id                     = var.provider_project_id
  subnetwork                     = local.gke_subnet_name
  cert_manager_issuer_email      = var.helm_cert_manager_issuer_email
  global_resource_prefix         = local.global_resource_prefix
  external_nginx_ingress_enabled = var.helm_external_nginx_ingress_enabled
  internal_nginx_ingress_enabled = var.helm_internal_nginx_ingress_enabled

  depends_on = [module.openvpn[0]]
}
