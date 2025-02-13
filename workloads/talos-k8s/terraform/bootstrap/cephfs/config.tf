resource "kubernetes_namespace" "ceph_csi_cephfs" {
  metadata {
    name = "ceph-csi-cephfs"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

data "http" "ceph_cluster_data" {
  url      = "${var.proxmox.auth.endpoint}/api2/json/cluster/ceph/status"
  insecure = var.proxmox.auth.insecure

  request_headers = {
    Accept        = "application/json"
    Authorization = "PVEAPIToken=${var.proxmox.auth.api_token}"
  }
}

locals {
  ceph_data   = jsondecode(data.http.ceph_cluster_data.response_body)["data"]
  cluster_id  = local.ceph_data["fsid"]
  monitors    = [for mon in local.ceph_data["monmap"]["mons"] : mon["addr"]]
}

resource "helm_release" "ceph_csi_cephfs" {
  name       = "ceph-csi-cephfs"
  namespace  = kubernetes_namespace.ceph_csi_cephfs.metadata[0].name
  repository = "https://ceph.github.io/csi-charts"
  chart      = "ceph-csi-cephfs"
  version    = "3.13.0"

  values     = [templatefile("${path.module}/files/values.yaml.tpl", {
    cluster_id = local.cluster_id
    pool = "cephfs_data"
    fsName = "cephfs"
    monitors   = local.monitors
    ceph_subvolume_group = "csi"
    rados_namespace = "csi"
    ceph_user  = var.ceph.auth.username
    ceph_key   = var.ceph.auth.key
  })]
}
