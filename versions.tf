terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }

  required_version = ">= 0.14"
}
