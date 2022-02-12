terraform {
  required_version = ">=1.1.5"

  required_providers {
    google = {
      source = "hashicorp/google"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}
