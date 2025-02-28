resource "kubernetes_manifest" "cilium_ip_pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "ip-pool"
    }
    spec = {
      blocks = [
        {
          start = "10.70.30.200"
          stop  = "10.70.30.250"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name      = "default-l2-announcement-policy"
    }
    spec = {
      externalIPs    = true
      loadBalancerIPs = true
    }
  }
}
