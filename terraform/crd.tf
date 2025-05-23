data "external" "version" {
  program = ["/bin/bash","${path.module}/latest.sh"]
}

# fetch a raw multi-resource yaml
data "http" "crd" {
  url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/${data.external.version.result.latest}/bundle.yaml"
}

resource "kubernetes_manifest" "crd" {
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(data.http.crd.response_body, "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(yaml)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value

}