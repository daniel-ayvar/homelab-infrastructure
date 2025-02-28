resource "kubernetes_namespace" "flux" {
  metadata {
    name = "flux"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "flux" {
  name       = "flux"
  namespace  = kubernetes_namespace.flux.metadata[0].name
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.14.1"

  values     = [templatefile("${path.module}/files/flux2.values.yaml.tpl", {})]
}

resource "kubernetes_secret" "flux_github_ssh" {
  metadata {
    name      = "flux-github-ssh"
    namespace  = kubernetes_namespace.flux.metadata[0].name
  }

  data = {
    "identity"     = var.gh_ssh_credentials.identity
    "identity.pub" = var.gh_ssh_credentials.identity_pub
    "known_hosts"  = var.gh_ssh_credentials.known_hosts
  }

  type = "Opaque"
}

resource "helm_release" "flux_sync" {
  depends_on = [helm_release.flux]
  name       = "flux-sync"
  namespace  = kubernetes_namespace.flux.metadata[0].name
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"
  version    = "1.10.0"

  values     = [templatefile("${path.module}/files/flux2-sync.values.yaml.tpl", {
        github_credential_secret_ref = kubernetes_secret.flux_github_ssh.metadata[0].name
        repository_url = "ssh://git@github.com/dayvar14/homelab-infrastructure-k8s.git"
        branch = "main"
    })]
}

