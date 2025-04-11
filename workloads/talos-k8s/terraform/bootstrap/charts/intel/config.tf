resource "kubernetes_namespace" "intel_gpu_device_plugin" {
  metadata {
    name = "intel-gpu-device-plugin"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "intel_gpu_device_plugin" {
  name       = "intel-gpu-device-plugin"
  namespace  = kubernetes_namespace.intel_gpu_device_plugin.metadata[0].name
  repository = "https://intel.github.io/helm-charts"
  chart      = "intel/intel-device-plugins-gpu"
  version    = "v4.10.0"
}
