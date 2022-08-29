terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}