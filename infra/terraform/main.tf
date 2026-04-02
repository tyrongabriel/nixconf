terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    talos = {
          source  = "siderolabs/talos"
          version = "0.7.0" # Use the latest stable
    }
  }
}

provider "sops" {}
provider "talos" {}

# Load your secrets
data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

# Host 1
provider "libvirt" {
  alias = "ltc01"
  uri   = "qemu+sshcmd://deploy@hp01.tail1c2108.ts.net/system"
}

# Host 2
provider "libvirt" {
  alias = "hp01"
  uri   = "qemu+sshcmd://deploy@hp01.tail1c2108.ts.net/system"
}

# The Base Image (One per host)
resource "libvirt_volume" "talos_base_ltc01" {
  provider = libvirt.ltc01
  name     = "talos-v1.12.6-base"
  pool     = "default"
  source   = "https://factory.talos.dev/image/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b/v1.12.6/nocloud-amd64.raw.xz"
  format   = "raw"
}

# The VM-specific Overlay
resource "libvirt_volume" "vm_disk_01" {
  provider       = libvirt.host1
  name           = "talos-node-01.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.talos_base_host1.id
  # This expands the disk for this specific VM to 40GB
  size           = 42949672960
  format         = "qcow2"
}
