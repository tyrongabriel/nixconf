variable "talos_version" {
  description = "The version of Talos OS to use"
  type        = string
  default     = "v1.12.6"
}

variable "cluster_name" {
  description = "The name of the Talos cluster"
  type        = string
  default     = "production"
}

variable "factory_image_url" {
  description = "The URL of the Talos factory image to use as the base volume"
  type        = string
  default     = "https://factory.talos.dev/image/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b/v1.7.0/nocloud-amd64.raw.xz"
}

variable "tailscale_domain" {
  description = "The Tailscale domain for the nodes"
  type        = string
  default     = "tail1c2108.ts.net"
}

variable "nodes" {
  description = "Map of nodes to provision"
  type = map(object({
    host      = string
    type      = string
    memory    = optional(number, 4096)
    vcpu      = optional(number, 2)
    disk_size = optional(number, 42949672960) # 40GB
    bootstrap = optional(bool, false)
  }))
  default = {
    "talos-ltc01-01" = { host = "ltc01", type = "controlplane", bootstrap = true }
    "talos-ltc01-02" = { host = "ltc01", type = "worker" }
    "talos-hp01-01"  = { host = "hp01", type = "controlplane" }
  }
}
