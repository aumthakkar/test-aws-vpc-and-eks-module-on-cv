terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.9"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.1"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.5"
    }
  }
}