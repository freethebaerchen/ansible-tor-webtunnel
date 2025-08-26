## Setup Archlinux x86_64-Servers
resource "hcloud_server" "archlinux-x86-apache" {
  name         = "archlinux-x86-apache"
  image        = data.hcloud_image.archlinux_x86_snapshot.id
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.archlinux_x86_snapshot
  ]
  labels = {
    "os"        = "archlinux"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "archlinux-x86-caddy" {
  name         = "archlinux-x86-caddy"
  image        = data.hcloud_image.archlinux_x86_snapshot.id
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.archlinux_x86_snapshot
  ]
  labels = {
    "os"        = "archlinux"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "archlinux-x86-nginx" {
  name         = "archlinux-x86-nginx"
  image        = data.hcloud_image.archlinux_x86_snapshot.id
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.archlinux_x86_snapshot
  ]
  labels = {
    "os"        = "archlinux"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for archlinux-x86-apache DNS records
resource "random_string" "archlinux_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for archlinux-x86-caddy DNS records
resource "random_string" "archlinux_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for archlinux-x86-nginx DNS records
resource "random_string" "archlinux_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  archlinux_dns_records = {
    archlinux_x86_apache = {
      name = random_string.archlinux_x86_apache_dns_name.result
      ipv4 = hcloud_server.archlinux-x86-apache.ipv4_address
      ipv6 = hcloud_server.archlinux-x86-apache.ipv6_address
    }
    archlinux_x86_caddy = {
      name = random_string.archlinux_x86_caddy_dns_name.result
      ipv4 = hcloud_server.archlinux-x86-caddy.ipv4_address
      ipv6 = hcloud_server.archlinux-x86-caddy.ipv6_address
    }
    archlinux_x86_nginx = {
      name = random_string.archlinux_x86_nginx_dns_name.result
      ipv4 = hcloud_server.archlinux-x86-nginx.ipv4_address
      ipv6 = hcloud_server.archlinux-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "archlinux_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.archlinux_dns_records : [
        {
          key     = "${server_name}-a"
          name    = server_data.name
          type    = "A"
          content = server_data.ipv4
        },
        {
          key     = "${server_name}-aaaa"
          name    = server_data.name
          type    = "AAAA"
          content = server_data.ipv6
        }
      ]
    ]) : pair.key => pair
  }

  zone_id = var.dns_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 360
}