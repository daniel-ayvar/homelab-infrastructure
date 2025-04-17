resource "kubernetes_namespace" "node_feature_discovery" {
  metadata {
    name = "nfd"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "node_feature_discovery" {
  name       = "node-feature-discovery"
  namespace  = kubernetes_namespace.node_feature_discovery.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/node-feature-discovery/charts"
  chart      = "node-feature-discovery"
  version    = "0.17.2"
}
