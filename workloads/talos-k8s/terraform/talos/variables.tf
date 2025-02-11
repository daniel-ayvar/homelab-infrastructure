variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name            = string
    endpoint        = string
    gateway         = string
    talos_version   = string
    proxmox_cluster = string
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node     = string
    machine_type  = string
    datastore_id  = optional(string, "local")
    ip            = string
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    update        = optional(bool, false)
    igpu = optional(object({
      enabled = optional(bool, false)
      mapping = optional(string, "")
    }), {})
  }))
}

variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url             = optional(string, "https://factory.talos.dev")
    extension_names         = list(string)
    version                 = string
    updated_extension_names = optional(list(string))
    update_version          = optional(string)
    arch                    = optional(string, "amd64")
    platform                = optional(string, "nocloud")
    proxmox_datastore       = optional(string, "local")
  })
}

variable "ceph_cluster_ips" {
  description = "Ceph cluster ip address to use in firewall rules"
  type = list(string)
}
