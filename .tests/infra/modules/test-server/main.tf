# Test Server Module
# This module creates a test server with DNS records and host_vars generation

resource "hcloud_ssh_key" "root_key" {
  name       = "root_ssh_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Create the server
resource "hcloud_server" "test_server" {
  name               = var.server_config.name
  image              = var.server_config.image
  server_type        = var.server_config.server_type
  ssh_keys           = [hcloud_ssh_key.root_key.id]
  location           = var.server_config.location
  firewall_ids       = var.server_config.firewall_ids
  backups            = false
  keep_disk          = false
  placement_group_id = var.server_config.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    os            = var.server_config.os
    hcloud_server = hcloud_server.test_server
  })

  labels = {
    "os"        = var.server_config.os
    "arch"      = var.server_config.arch
    "webserver" = var.server_config.webserver
  }
}

# Generate random DNS name
resource "random_string" "dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Create DNS records
resource "cloudflare_dns_record" "a_record" {
  zone_id = var.dns_zone_id
  name    = random_string.dns_name.result
  type    = "A"
  content = hcloud_server.test_server.ipv4_address
  ttl     = 360
}

resource "cloudflare_dns_record" "aaaa_record" {
  zone_id = var.dns_zone_id
  name    = random_string.dns_name.result
  type    = "AAAA"
  content = hcloud_server.test_server.ipv6_address
  ttl     = 360
}

# Generate host_vars file
resource "local_file" "host_vars" {
  filename = "${path.root}/../../host_vars/${var.server_config.name}.yaml"
  content = templatefile("${path.module}/templates/host_vars.tftpl", {
    dns_name  = random_string.dns_name.result
    os        = var.server_config.os
    webserver = var.server_config.webserver
    arch      = var.server_config.arch == "x86_64" ? "x86" : var.server_config.arch
  })
}
