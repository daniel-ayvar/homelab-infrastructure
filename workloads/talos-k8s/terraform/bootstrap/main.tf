module "k8s_ceph_rbd" {
  source = "./charts/ceph-rbd/"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  proxmox = var.proxmox
  ceph    = var.ceph

}

module "k8s_cephfs" {
  source = "./charts/cephfs/"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  proxmox = var.proxmox
  ceph    = var.ceph
}

module "k8s_cilium" {
  source = "./charts/cilium/"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "k8s_nfs" {
  source = "./charts/nfs/"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

data "infisical_secrets" "infra_secrets" {
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

locals {
  gh_ssh_credentials = {
    identity     = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_IDENTITY_KEY_B64"].value)
    identity_pub = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_PUBLIC_IDENTITY_KEY_B64"].value)
    known_hosts  = base64decode(data.infisical_secrets.infra_secrets.secrets["GH_SSH_KNOWN_HOSTS_B64"].value)
  }
}

module "k8s_flux" {
  source = "./charts/flux/"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  gh_ssh_credentials = local.gh_ssh_credentials
}

module "k8s_external_secrets" {
  source = "./charts/external-secrets/"

  providers = {
    infisical  = infisical
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
  }
  infisical_workspace_id = data.infisical_secrets.infra_secrets.secrets["INFISICAL_ORG_ID"].value

}
