locals {
  version        = var.image.version
  update_version = coalesce(var.image.update_version, var.image.version)
}

data "talos_image_factory_extensions_versions" "extension_versions" {
  talos_version = local.version
  filters = {
    names = var.image.extension_names
  }
}

resource "talos_image_factory_schematic" "schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.extension_versions.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_extensions_versions" "update_extension_versions" {
  talos_version = local.update_version
  filters = {
    names = var.image.updated_extension_names
  }
}

resource "talos_image_factory_schematic" "update_schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.update_extension_versions.extensions_info.*.name
        }
      }
    }
  )
}

locals {
  image_id        = talos_image_factory_schematic.schematic.id
  update_image_id = talos_image_factory_schematic.update_schematic.id
}

locals {
  unique_host_nodes = distinct([
    for node in values(var.nodes) : node.host_node
  ])

  unique_nodes = {
    for host in local.unique_host_nodes : host => (
      [for node in reverse(values(var.nodes)) : node if node.host_node == host][0]
    )
  }
}

resource "proxmox_virtual_environment_download_file" "this" {
  for_each = local.unique_nodes

  node_name               = each.key
  content_type            = "iso"
  datastore_id            = var.image.proxmox_datastore
  file_name               = "talos-${each.value.update ? local.update_image_id : local.image_id}-${each.value.update ? local.update_version : local.version}-${var.image.platform}-${var.image.arch}.img"
  url                     = "${var.image.factory_url}/image/${each.value.update ? local.update_image_id : local.image_id}/${each.value.update ? local.update_version : local.version}/${var.image.platform}-${var.image.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}
