resource "macaddress" "ve_mac_address" {
  for_each = toset(["ctrl-00", "ctrl-01", "ctrl-02", "work-00", "work-01", "work-02"])
}

locals {
  proxmox_nodes = ["minis01", "minis02", "minis03"]
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "igpu" {
  comment = "Created in terraform"
  name    = "iGPU"
  map = [
    for node in local.proxmox_nodes : {
      comment      = "Created in terraform for ${node}"
      id           = "8086:46a6"
      iommu_group  = 0
      node         = node
      path         = "0000:00:02.0"
      subsystem_id = "8086:2212"
    }
  ]
  mediated_devices = false
}

locals {
  cluster = {
    name            = "homelab-cluster"
    endpoint        = "10.70.30.30"
    gateway         = "10.70.30.1"
    talos_version   = "v1.7"
    proxmox_cluster = "pve-cluster"
  }

  nodes = {
    "ctrl-00" = {
      machine_type  = "controlplane"
      ip            = "10.70.30.30"
      mac_address   = upper(macaddress.ve_mac_address["ctrl-00"].address)
      host_node     = "minis01"
      vm_id         = 800
      cpu           = 4
      ram_dedicated = 8192
    }
    "ctrl-01" = {
      machine_type  = "controlplane"
      ip            = "10.70.30.31"
      mac_address   = upper(macaddress.ve_mac_address["ctrl-01"].address)
      host_node     = "minis02"
      vm_id         = 801
      cpu           = 4
      ram_dedicated = 8192
    }
    "ctrl-02" = {
      machine_type  = "controlplane"
      ip            = "10.70.30.32"
      mac_address   = upper(macaddress.ve_mac_address["ctrl-02"].address)
      host_node     = "minis03"
      vm_id         = 802
      cpu           = 4
      ram_dedicated = 8192
    }
    "work-00" = {
      machine_type  = "worker"
      ip            = "10.70.30.40"
      mac_address   = upper(macaddress.ve_mac_address["work-00"].address)
      host_node     = "minis01"
      vm_id         = 810
      cpu           = 8
      ram_dedicated = 24576
      igpu = {
        enabled = true
        mapping = proxmox_virtual_environment_hardware_mapping_pci.igpu.name
      }
    }
    "work-01" = {
      machine_type  = "worker"
      ip            = "10.70.30.41"
      mac_address   = upper(macaddress.ve_mac_address["work-01"].address)
      host_node     = "minis02"
      vm_id         = 811
      cpu           = 8
      ram_dedicated = 24576
      igpu = {
        enabled = true
        mapping = proxmox_virtual_environment_hardware_mapping_pci.igpu.name
      }
    }
    "work-02" = {
      machine_type  = "worker"
      ip            = "10.70.30.42"
      mac_address   = upper(macaddress.ve_mac_address["work-02"].address)
      host_node     = "minis03"
      vm_id         = 812
      cpu           = 8
      ram_dedicated = 24576
      igpu = {
        enabled = true
        mapping = proxmox_virtual_environment_hardware_mapping_pci.igpu.name
      }
    }
  }
}

module "talos" {
  source = "./talos"

  providers = {
    proxmox  = proxmox
    helm     = helm
    routeros = routeros
  }

  image = {
    extension_names = ["siderolabs/i915", "siderolabs/intel-ucode", "siderolabs/qemu-guest-agent"]
    version         = "v1.9.3"
  }

  cluster = local.cluster

  nodes            = local.nodes
  ceph_cluster_ips = var.ceph.cluster_ips
}

resource "infisical_secret" "talos_kube_config_b64" {
  name         = "TALOS_KUBE_CONFIG_B64"
  value        = base64encode(module.talos.kube_config.kubeconfig_raw)
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "talos_config_b64" {
  name         = "TALOS_CONFIG_B64"
  value        = base64encode(module.talos.client_configuration.talos_config)
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}
