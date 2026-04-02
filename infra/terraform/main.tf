terraform {
  required_version = ">= 1.6.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0"
    }
  }
}

provider "sops" {}

provider "talos" {}

# Host ltc01
provider "libvirt" {
  alias = "ltc01"
  uri   = "qemu+ssh://deploy@ltc01.tail1c2108.ts.net/system"
}

# Host hp01
provider "libvirt" {
  alias = "hp01"
  uri   = "qemu+ssh://deploy@hp01.tail1c2108.ts.net/system"
}

# Load encrypted secrets
data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}
