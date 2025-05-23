# prometheus-operator-newrelic-exporter
<!--
![GitHub release (latest by date)](https://img.shields.io/github/v/release/nesma-m7md/prometheus-operator-newrelic-exporter)
![GitHub issues](https://img.shields.io/github/issues/nesma-m7md/prometheus-operator-newrelic-exporter)
![GitHub license](https://img.shields.io/github/license/nesma-m7md/prometheus-operator-newrelic-exporter)

A Kubernetes integration that uses Prometheus Operator's PodMonitor and ServiceMonitor CRDs to scrape metrics and forward them to New Relic deployable via Terraform.

---
--->

## Why this solution?

Some services—such as internal dashboards or managed service pods (e.g., RabbitMQ Management)—can’t be monitored directly by New Relic agents. This exporter solves that by using Prometheus Operator to scrape those internal metrics, and pushes them to New Relic’s Metrics API.

You can then build full dashboards, set alerts, and unify observability across systems that are normally disconnected from New Relic.

---

## Features

- ✅ Scrape targets using **PodMonitor** (this example focuses on PodMonitor; ServiceMonitor support can be added similarly)
- 🔄 Export metrics to New Relic Metrics API
- ⚙️ Deploy using Terraform
- 🔐 Secure API key handling via Kubernetes secrets
- 🌐 Works across any Prometheus-compatible exporters

---

## Getting Started

### Prerequisites

- A Kubernetes cluster with Prometheus Operator installed
- A New Relic account with API key
- Terraform and `kubectl` installed

---

## 📦  Terraform Deployment

You can deploy this using Terraform. Follow these steps:

Clone this repository to your local machine.

Ensure you have the following installed:

Terraform (>= 1.0)

kubectl configured to access your Kubernetes cluster

Navigate to the terraform/ directory inside the repo.

Export your New Relic API key and your app namespace as a Terraform variable (or use a .tfvars file).

Remember to Edit the podmonitor.tf  file with your correct information

Initialize and apply Terraform:

```bash terraform init ```
```bash terraform apply ```

---

## ✅ Verify Your Setup

### 1. Verify from Prometheus

To ensure Prometheus is successfully scraping your targets, port-forward the Prometheus server pod and check its targets page:

```bash
kubectl -n monitoring port-forward svc/prometheus-operated 9090:9090
```



### 2. Verify in New Relic

Once deployed, head to your [New Relic dashboard](https://one.newrelic.com/) and check the **Metrics Explorer** to confirm data is arriving.

You can filter metrics by the `namespace` you configured (e.g., `monitoring`) to validate that your `PodMonitor` targets are being scraped and exported correctly.

> **Tip:** Search by metric name prefix or label to narrow down your view.


---

## 📚 Resources

[Prometheus Operator Installation Guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/getting-started/installation.md)

[New Relic Prometheus Integration Docs](https://docs.newrelic.com/docs/infrastructure/prometheus-integrations/install-configure-remote-write/set-your-prometheus-remote-write-integration/)

