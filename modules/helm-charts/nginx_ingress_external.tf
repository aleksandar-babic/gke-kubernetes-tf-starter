resource "google_compute_address" "ingress_external" {
  count = var.external_nginx_ingress_enabled ? 1 : 0

  name = "${var.global_resource_prefix}-nginx-ingress-external"
}

resource "helm_release" "nginx_ingress_external" {
  count = var.external_nginx_ingress_enabled ? 1 : 0

  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.0.17"
  name             = "nginx-ingress-external"
  namespace        = "nginx-ingress-external"
  create_namespace = true

  values = [
    file("${path.module}/values/nginx_ingress.yaml.tftpl")
  ]

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }
  set {
    name  = "controller.ingressClassResource.enabled"
    value = true
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }
  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.ingress_external[0].address
  }
  set {
    name  = "controller.daemonset.useHostPort"
    value = false
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.publishService.enabled"
    value = true
  }
  set {
    name  = "controller.resources.requests.memory"
    type  = "string"
    value = "140Mi"
  }
}
