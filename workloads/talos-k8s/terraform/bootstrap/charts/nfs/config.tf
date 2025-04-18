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

  set {
    name  = "externalSnapshotter.enabled"
    value = "true"
  }
}

resource "kubectl_manifest" "nfs_csi_snapshot_class" {
  yaml_body = <<YAML
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-nfs-snapclass
driver: nfs.csi.k8s.io
deletionPolicy: Delete
YAML
}
