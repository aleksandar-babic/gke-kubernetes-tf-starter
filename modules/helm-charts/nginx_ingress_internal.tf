resource "google_compute_address" "ingress_internal" {
  count = var.internal_nginx_ingress_enabled ? 1 : 0

  name         = "${var.global_resource_prefix}-nginx-ingress-internal"
  address_type = "INTERNAL"
  subnetwork   = var.subnetwork
  purpose      = "SHARED_LOADBALANCER_VIP"
}

resource "helm_release" "nginx_ingress_internal" {
  count = var.internal_nginx_ingress_enabled ? 1 : 0

  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.0.17"
  name             = "nginx-ingress-internal"
  namespace        = "nginx-ingress-internal"
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
    value = "nginx-internal"
  }
  set {
    name  = "controller.ingressClassResource.enabled"
    value = true
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = false
  }
  set {
    name  = "controller.ingressClassResource.controllerValue"
    value = "k8s.io/internal-ingress-nginx"
  }
  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "controller.service.external.enabled"
    value = false
  }
  set {
    name  = "controller.service.internal.enabled"
    value = true
  }
  set {
    name  = "controller.service.internal.annotations.networking\\.\\gke\\.io/load-balancer-type"
    value = "Internal"
  }
  set {
    name  = "controller.service.internal.loadBalancerIP"
    value = google_compute_address.ingress_internal[0].address
  }
  set {
    name  = "controller.service.internal.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.daemonset.useHostPort"
    value = false
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
