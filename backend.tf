terraform {
  backend "gcs" {
    prefix = "terraform/gke-k8s-tf-starter/state"
  }
}
