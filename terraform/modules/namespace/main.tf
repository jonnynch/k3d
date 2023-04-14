terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SET MODULE DEPENDENCY RESOURCE
# This works around a terraform limitation where we can not specify module dependencies natively.
# See https://github.com/hashicorp/terraform/issues/1178 for more discussion.
# By resolving and computing the dependencies list, we are able to make all the resources in this module depend on the
# resources backing the values in the dependencies list.
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "dependency_getter" {
  triggers = {
    instance = join(",", var.dependencies)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE NAMESPACE
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "namespace" {
  count      = var.create_resources ? 1 : 0
  depends_on = [null_resource.dependency_getter]

  metadata {
    name        = var.name
    labels      = var.labels
    annotations = var.annotations
  }
}

resource "kubernetes_secret" "regcred" {
  metadata {
    name = "regcred"
    namespace = var.name
  }

  data = {
    ".dockerconfigjson" = "${file("${path.root}/.docker/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "ingress" {
  metadata {
    name = "ingress"
    namespace = var.name
  }

  data = {
    "tls.crt" = "${file("${path.root}/.tls/${var.name}/tls.crt")}"
    "tls.key" = "${file("${path.root}/.tls/${var.name}/tls.key")}"
  }

  type = "kubernetes.io/tls"
}