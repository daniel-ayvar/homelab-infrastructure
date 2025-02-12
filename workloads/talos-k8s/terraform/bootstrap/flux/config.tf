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

data "infisical_secrets" "infra_secrets" {
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}


resource "kubernetes_secret" "flux_github_ssh" {
  metadata {
    name      = "flux-github-ssh"
    namespace  = kubernetes_namespace.flux.metadata[0].name
  }

  data = {
    "identity"     = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_IDENTITY_KEY_B64"].value)
    "identity.pub" = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_PUBLIC_IDENTITY_KEY_B64"].value)
    "known_hosts"  = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_KNOWN_HOSTS_B64"].value)
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

