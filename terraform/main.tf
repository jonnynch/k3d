terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
provider "kubernetes" {
  config_context = var.kubectl_config_context_name
  config_path    = var.kubectl_config_path
}

module "namespace" {
  source           = "./modules/namespace"
  create_resources = var.create_resources
  name             = var.name
}