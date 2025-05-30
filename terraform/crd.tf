data "external" "version" {
  program = ["/bin/bash","${path.module}/latest.sh"]
}

# 1. Fetch the multi-document YAML bundle
data "http" "crd" {
  url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/${data.external.version.result.latest}/bundle.yaml"
  request_headers = {
    Accept = "text/plain"
  }
}

# 2. Split and decode all YAML docs
locals {
  yaml_docs = [
    for yaml in split("\n---\n", data.http.crd_bundle.response_body) :
    yamldecode(yaml)
    if length(trimspace(yaml)) > 0
  ]

  # 3. Filter out only the CRDs
  crds = {
    for doc in local.yaml_docs :
    "${doc.kind}--${doc.metadata.name}" => doc
    if doc.kind == "CustomResourceDefinition"
  }

  # 4. Filter out everything else (CRs, Roles, Deployments, etc.)
  other_resources = {
    for doc in local.yaml_docs :
    "${doc.kind}--${doc.metadata.name}" => doc
    if doc.kind != "CustomResourceDefinition"
  }
}

# 5. Apply CRDs first
resource "kubectl_manifest" "crds" {
  for_each  = local.crds
  yaml_body = yamlencode(each.value)
  server_side_apply = true
  force_conflicts   = true
}

# 6. Apply remaining resources after CRDs are created
resource "kubectl_manifest" "resources" {
  for_each = local.other_resources
  yaml_body = yamlencode(each.value)

  depends_on = [kubectl_manifest.crds]
}