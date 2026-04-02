resource "libvirt_volume" "vm_disk" {
  pool = "default"
  for_each       = var.nodes
  # Logic to pick host1 or host2 provider based on each.value.host
  # Note: Libvirt provider selection with for_each requires separate modules or
  # duplicated blocks if hosts are truly distinct. For simplicity:
  name           = "${each.key}-disk.qcow2"
  base_volume_id = each.value.host == "host1" ? libvirt_volume.talos_base_host1.id : libvirt_volume.talos_base_host2.id
  size           = 42949672960
}

resource "libvirt_domain" "talos_node" {
  type = "qemu"
  provider = libvirt.ltc01
  name     = "talos-ltc01-01"
  memory   = "4096"
  vcpu     = 2

  disk {
    volume_id = libvirt_volume.vm_disk_01.id
  }

  # Pass the Talos config via 'user_data' (cloud-init style)
  # or use the Talos Provider to apply it over the network
  fw_cfg {
    name  = "opt/org.talos.config"
    value = data.talos_machine_configuration.node.machine_configuration
  }
}
