#################### Variable ####################

variable "newrelic_api_key" {
  type      = string
  sensitive = true
}

variable "newrelic_namespace" {
  type      = string
}

#################### Provider ####################

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.0.0"
    }

  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

#################### Prometheus ####################

resource "kubernetes_secret" "nr-l" {
  metadata {
    name      = "nr-license-key"
    namespace = "default"
  }

  data = {
    value = var.newrelic_api_key
  }

  type = "Opaque"
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }
  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/metric", "pods", "endpoints", "services"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}
resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "default"
  }
}

resource "kubectl_manifest" "prometheus" {
  yaml_body  = <<-EOT
    apiVersion: monitoring.coreos.com/v1
    kind: Prometheus
    metadata:
      name: prometheus
      namespace: default
    spec:
      enableAdminAPI: false
      podMonitorSelector:
        matchLabels:
          team: monitor
      serviceMonitorSelector:
        matchLabels:
          team: monitor
      scrapeConfigSelector:
        matchLabels:
          team: monitor
      remoteWrite:
        - authorization:
            credentials:
              key: value
              name: nr-license-key
          url: "https://metric-api.newrelic.com/prometheus/v1/write?prometheus_server=${var.namespace}"
      resources:
        requests:
          memory: 400Mi
      serviceAccountName: prometheus
  EOT
  depends_on = [kubernetes_manifest.crd]
}

