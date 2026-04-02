resource "libvirt_domain" "talos_node" {
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

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "my-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://controlplane.tailnet-name.ts.net:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "talos-ltc01-01"
        }
        install = {
          disk = "/dev/vda" # Standard for libvirt
        }
      }
    }),
    # Injected Tailscale Patch
    templatefile("${path.module}/../../talos/patches/tailscale.yaml", {
      tailscale_key = data.sops_file.secrets.data["tailscale_auth_key"]
    })
  ]
}

resource "talos_machine_configuration_apply" "cp_node" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = "talos-ltc01-01.tail1c2108.ts.net" # The temporary local IP or Tailscale IP if reachable

  # Ensure the VM exists before trying to configure it
  depends_on = [libvirt_domain.talos_node]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.cp_node]
  node       = "talos-ltc01-01.tail1c2108.ts.net"
  client_configuration = talos_machine_secrets.this.client_configuration
}
