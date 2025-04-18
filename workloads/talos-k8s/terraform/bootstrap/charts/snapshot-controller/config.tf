resource "kubernetes_namespace" "snapshot_controller" {
  metadata {
    name = "snapshot-controller"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "snapshot_controller" {
  name       = "snapshot-controller"
  namespace  = kubernetes_namespace.snapshot_controller.metadata[0].name
  repository = "https://piraeus.io/helm-charts/"
  chart      = "snapshot-controller"
  version    = "4.0.2"
}
