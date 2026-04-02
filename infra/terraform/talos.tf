resource "talos_machine_secrets" "this" {
  talos_version = "v1.12.6"
}

data "talos_client_configuration" "this" {
  cluster_name         = "production"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = ["ltc01.tail1c2108.ts.net", "hp01.tail1c2108.ts.net"]
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}
