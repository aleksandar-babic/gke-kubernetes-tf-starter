resource "google_service_account" "cert_manager_dns_solver" {
  account_id   = "${var.global_resource_prefix}-cert-manager"
  display_name = "${var.global_resource_prefix}-cert-manager"
}

resource "google_service_account_iam_binding" "cert_manager_dns_solver_workload_identity_cert_manager" {
  service_account_id = google_service_account.cert_manager_dns_solver.id
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"]
}

resource "google_project_iam_member" "cert_manager_dns_admin" {
  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.cert_manager_dns_solver.email}"
}

resource "helm_release" "cert_manager" {
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.6.1"
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = google_service_account.cert_manager_dns_solver.email
  }
}

resource "kubectl_manifest" "letsencrypt_cluster_issuer_dns" {
  validate_schema = false
  yaml_body       = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    email: ${var.cert_manager_issuer_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.project_id}
YAML

  depends_on = [helm_release.cert_manager]
}
