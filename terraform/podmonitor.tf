resource "kubectl_manifest" "pod_monitor" {
  yaml_body  = <<-EOT
    apiVersion: monitoring.coreos.com/v1
    kind: PodMonitor
    metadata:
      name: monitor-my-pod
      namespace: default
      labels:
        team: monitor
    spec:
      jobLabel: my-pod-scraping
      namespaceSelector:
        matchNames:
        - ${var.namespace}

      podMetricsEndpoints:
      - path: /monitor
        port: 80
        scheme: http
      selector:
        matchLabels:
          app: my-app
  EOT
}