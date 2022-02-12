subnet_cidrs = {
  gke          = "100.64.0.0/20"
  gke_services = "100.64.48.0/20"
  gke_pods     = "100.64.96.0/20"
}

gke_cluster_autoscaling = {
  enabled       = true
  min_cpu_cores = 6
  min_memory_gb = 6
  max_cpu_cores = 12
  max_memory_gb = 12
  gpu_resources = []
}

gke_node_pools = [
  {
    name                        = "core"
    machine_type                = "n1-custom-2-2048"
    preemptible                 = true
    disk_type                   = "pd-standard"
    disk_size_gb                = 80
    autoscaling                 = true
    auto_repair                 = true
    sandbox_enabled             = false
    cpu_manager_policy          = "static"
    cpu_cfs_quota               = true
    enable_integrity_monitoring = true
    enable_secure_boot          = true
  },
]

gke_initial_node_count = 1
