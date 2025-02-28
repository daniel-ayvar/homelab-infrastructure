resource "kubernetes_namespace" "ceph_csi_rbd" {
  metadata {
    name = "ceph-csi-rbd"
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

# Generate values.yaml from the template file
locals {
  ceph_data   = jsondecode(data.http.ceph_cluster_data.response_body)["data"]
  cluster_id  = local.ceph_data["fsid"]
  monitors    = [for mon in local.ceph_data["monmap"]["mons"] : mon["addr"]]
}

# Deploy Helm release using the generated values.yaml
resource "helm_release" "ceph_rbd_csi" {
  name       = "ceph-csi-rbd"
  namespace  = kubernetes_namespace.ceph_csi_rbd.metadata[0].name
  repository = "https://ceph.github.io/csi-charts"
  chart      = "ceph-csi-rbd"
  version    = "3.13.0"

  values     = [templatefile("${path.module}/files/ceph-values.yaml.tpl", {
    cluster_id = local.cluster_id
    monitors   = local.monitors
    ceph_user  = var.ceph.auth.username
    ceph_key   = var.ceph.auth.key
  })]
}
