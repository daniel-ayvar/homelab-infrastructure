resource "kubernetes_namespace" "nfs_csi" {
  metadata {
    name = "nfs-csi"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "nfs_csi" {
  name       = "nfs-csi"
  namespace  = kubernetes_namespace.nfs_csi.metadata[0].name
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  version    = "v4.10.0"
}

resource "kubernetes_manifest" "nfs_csi_storage_class" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "nfs-csi"
    }
    provisioner = "nfs.csi.k8s.io"
    parameters = {
      server = "10.70.30.10"
      share  = "/mnt/backblaze_backup_pool/data"
    }
    reclaimPolicy        = "Retain"
    volumeBindingMode    = "Immediate"
    allowVolumeExpansion = true
  }
}
