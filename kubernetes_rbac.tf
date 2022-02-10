resource "kubernetes_cluster_role_binding" "admin" {
  for_each = toset(var.gke_cluster_admins)

  metadata {
    name = "cluster-admin-${each.value}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = each.value
    api_group = "rbac.authorization.k8s.io"
  }
}
