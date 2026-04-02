terraform {
  required_version = ">= 1.6.0"

  encryption {
    key_provider "pbkdf2" "my_passphrase" {
      # It is best to pass this via an environment variable rather than hardcoding
      # Looks for  TOFU_KMS_PBKDF2_MY_PASSPHRASE_PASSPHRASE
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "my_method" {
      keys = key_provider.pbkdf2.my_passphrase
    }
    state {
      method = method.aes_gcm.my_method
    }
    plan {
      method = method.aes_gcm.my_method
    }
  }

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

variable "state_passphrase" {
  type    = string
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
