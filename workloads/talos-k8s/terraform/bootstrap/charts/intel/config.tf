resource "kubernetes_namespace" "intel" {
  metadata {
    name = "intel"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "intel_device_plugin_operator" {
  name       = "device-plugin-operator"
  namespace  = kubernetes_namespace.intel.metadata[0].name
  repository = "https://intel.github.io/helm-charts"
  chart      = "intel-device-plugins-operator"
  version    = "0.32.0"
}

resource "helm_release" "intel_device_plugins_gpu" {
  depends_on = [helm_release.intel_device_plugin_operator]
  name       = "gpu-device-plugin"
  namespace  = kubernetes_namespace.intel.metadata[0].name
  repository = "https://intel.github.io/helm-charts"
  chart      = "intel-device-plugins-gpu"
  version    = "0.32.0"
}
