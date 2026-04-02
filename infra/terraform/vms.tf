# Storage pools
resource "libvirt_pool" "default_ltc01" {
  provider = libvirt.ltc01
  name     = "default"
  type     = "dir"
  target {
    path = "/var/lib/libvirt/images"
  }
}

resource "libvirt_pool" "default_hp01" {
  provider = libvirt.hp01
  name     = "default"
  type     = "dir"
  target {
    path = "/var/lib/libvirt/images"
  }
}

# Base volumes per libvirt host
resource "libvirt_volume" "talos_base_ltc01" {
  provider = libvirt.ltc01
  name     = "talos-base.raw"
  pool     = libvirt_pool.default_ltc01.name
  source   = var.factory_image_url
  format   = "raw"
}

resource "libvirt_volume" "talos_base_hp01" {
  provider = libvirt.hp01
  name     = "talos-base.raw"
  pool     = libvirt_pool.default_hp01.name
  source   = var.factory_image_url
  format   = "raw"
}

# VM-specific Overlay volumes
resource "libvirt_volume" "vm_disk_ltc01" {
  for_each       = { for k, v in var.nodes : k => v if v.host == "ltc01" }
  provider       = libvirt.ltc01
  name           = "${each.key}.qcow2"
  pool           = libvirt_pool.default_ltc01.name
  base_volume_id = libvirt_volume.talos_base_ltc01.id
  size           = each.value.disk_size
  format         = "qcow2"
}

resource "libvirt_volume" "vm_disk_hp01" {
  for_each       = { for k, v in var.nodes : k => v if v.host == "hp01" }
  provider       = libvirt.hp01
  name           = "${each.key}.qcow2"
  pool           = libvirt_pool.default_hp01.name
  base_volume_id = libvirt_volume.talos_base_hp01.id
  size           = each.value.disk_size
  format         = "qcow2"
}

# Talos Secrets and Machine Configuration
resource "talos_machine_secrets" "this" {}

locals {
  # Patch Talos configuration to inject the Tailscale Auth Key and install the extension if provided by the factory image
  tailscale_patch = yamlencode({
    machine = {
      env = {
        TS_AUTHKEY = data.sops_file.secrets.data["tailscale_auth_key"]
      }
    }
  })


  cp_yaml_patches = [
    for f in fileset("${path.module}/../talos/patches/controlplane", "*.yaml") : file("${path.module}/../talos/patches/controlplane/${f}")
  ]
  worker_yaml_patches = [
    for f in fileset("${path.module}/../talos/patches/worker", "*.yaml") : file("${path.module}/../talos/patches/worker/${f}")
  ]

  # Combine them all together
  cp_all_patches     = concat([local.tailscale_patch], local.cp_yaml_patches)
  worker_all_patches = concat([local.tailscale_patch], local.worker_yaml_patches)
}

# Per-role config (controlplane/worker)
data "talos_machine_configuration" "controlplane" {
  cluster_name = var.cluster_name
  # This endpoint needs to be a stable IP/DNS, for example, the first controlplane node or a load balancer
  cluster_endpoint = "https://ncvps02.${var.tailscale_domain}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches   = local.cp_all_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://ncvps02.${var.tailscale_domain}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches   = local.worker_all_patches
}

# Ignition Configurations -> per host -> per machine
resource "libvirt_ignition" "talos_config_ltc01" {
  for_each = { for k, v in var.nodes : k => v if v.host == "ltc01" }
  provider = libvirt.ltc01
  name     = "${each.key}-config.ign"
  pool     = libvirt_pool.default_ltc01.name
  content  = each.value.type == "controlplane" ? data.talos_machine_configuration.controlplane.machine_configuration : data.talos_machine_configuration.worker.machine_configuration
}

resource "libvirt_ignition" "talos_config_hp01" {
  for_each = { for k, v in var.nodes : k => v if v.host == "hp01" }
  provider = libvirt.hp01
  name     = "${each.key}-config.ign"
  pool     = libvirt_pool.default_hp01.name
  content  = each.value.type == "controlplane" ? data.talos_machine_configuration.controlplane.machine_configuration : data.talos_machine_configuration.worker.machine_configuration
}

# Libvirt Domains
resource "libvirt_domain" "talos_node_ltc01" {
  for_each    = { for k, v in var.nodes : k => v if v.host == "ltc01" }
  provider    = libvirt.ltc01
  name        = each.key
  memory      = each.value.memory
  vcpu        = each.value.vcpu
  type        = "kvm"
  fw_cfg_name = "opt/org.talos.config"

  disk {
    volume_id = libvirt_volume.vm_disk_ltc01[each.key].id
  }

  network_interface {
    network_name = "default"
  }

  coreos_ignition = libvirt_ignition.talos_config_ltc01[each.key].id
}

resource "libvirt_domain" "talos_node_hp01" {
  for_each    = { for k, v in var.nodes : k => v if v.host == "hp01" }
  provider    = libvirt.hp01
  name        = each.key
  memory      = each.value.memory
  vcpu        = each.value.vcpu
  type        = "kvm"
  fw_cfg_name = "opt/org.talos.config"

  disk {
    volume_id = libvirt_volume.vm_disk_hp01[each.key].id
  }

  network_interface {
    network_name = "default"
  }

  coreos_ignition = libvirt_ignition.talos_config_hp01[each.key].id
}

# Client config output
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.nodes : "${k}.${var.tailscale_domain}" if v.type == "controlplane"]
  nodes                = [for k, v in var.nodes : "${k}.${var.tailscale_domain}"]
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}


### BOOTSTRAP ###
locals {
  # Find the key of the node that has bootstrap set to true
  bootstrap_node = [for k, v in var.nodes : k if v.bootstrap][0]
}

# 1. Automatically bootstrap the cluster on the designated node
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    libvirt_domain.talos_node_ltc01,
    libvirt_domain.talos_node_hp01
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = "${local.bootstrap_node}.${var.tailscale_domain}"
}

# 2. Automatically fetch the Kubernetes Kubeconfig once bootstrapped
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = "${local.bootstrap_node}.${var.tailscale_domain}"
}

# Output the Kubeconfig alongside the Talosconfig
output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
