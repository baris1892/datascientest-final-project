terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.3.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # path to Kubernetes configuration file
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
  }
}
