variable "hosts" {
  default = {
    "ltc01" = { name="ltc01", ip = "100.100.200.25", provider_uri = "qemu+sshcmd://deploy@ltc01.tail1c2108.ts.net/system" }
    "hp01" = { name="hp01", ip = "100.66.185.12", provider_uri = "qemu+sshcmd://deploy@hp01.tail1c2108.ts.net/system" }
  }
}

variable "nodes" {
  default = {
    "talos-ltc01-01" = { host = "ltc01", ip = "", type = "controlplane" }
    "talos-ltc01-02" = { host = "ltc01", ip = "100.100.200.28", type = "worker" }
    "talos-hp01-01" = { host = "hp01", ip = "100.66.185.13", type = "controlplane" }
  }
}

variable "tailscale-domain" {
  default = "tail1c2108.ts.net"
}
