resource "google_service_account" "external_dns" {
  account_id   = "${var.global_resource_prefix}-external-dns"
  display_name = "${var.global_resource_prefix}-external-dns"
}

resource "google_service_account_iam_binding" "external_dns_workload_identity_external_dns" {
  service_account_id = google_service_account.external_dns.id
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"]
}

resource "google_project_iam_member" "external_dns_dns_admin" {
  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "helm_release" "external_dns" {
  chart            = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "6.1.1"
  name             = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  set {
    name  = "provider"
    value = "google"
  }

  set {
    name  = "google.project"
    value = var.project_id
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = google_service_account.external_dns.email
  }

  set {
    name  = "metrics.enabled"
    value = true
  }
}
