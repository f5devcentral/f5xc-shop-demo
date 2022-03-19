terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.13.1"
    }
  }
}