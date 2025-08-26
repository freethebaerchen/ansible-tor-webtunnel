## Setup OpenSuse Leap Arm64-Servers
resource "hcloud_server" "suse-arm-apache" {
  name         = "suse-arm-apache"
  image        = "opensuse-15"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "arm"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "suse-arm-caddy" {
  name         = "suse-arm-caddy"
  image        = "opensuse-15"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "arm"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "suse-arm-nginx" {
  name         = "suse-arm-nginx"
  image        = "opensuse-15"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "arm"
    "webserver" = "nginx"
  }
}

## Setup OpenSuse Leap x86_64-Servers
resource "hcloud_server" "suse-x86-apache" {
  name         = "suse-x86-apache"
  image        = "opensuse-15"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "suse-x86-caddy" {
  name         = "suse-x86-caddy"
  image        = "opensuse-15"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "suse-x86-nginx" {
  name         = "suse-x86-nginx"
  image        = "opensuse-15"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "suse"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for suse-arm-apache DNS records
resource "random_string" "suse_arm_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for suse-arm-caddy DNS records
resource "random_string" "suse_arm_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for suse-arm-nginx DNS records
resource "random_string" "suse_arm_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for suse-x86-apache DNS records
resource "random_string" "suse_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for suse-x86-caddy DNS records
resource "random_string" "suse_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for suse-x86-nginx DNS records
resource "random_string" "suse_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  suse_dns_records = {
    suse_arm_apache = {
      name = random_string.suse_arm_apache_dns_name.result
      ipv4 = hcloud_server.suse-arm-apache.ipv4_address
      ipv6 = hcloud_server.suse-arm-apache.ipv6_address
    }
    suse_arm_caddy = {
      name = random_string.suse_arm_caddy_dns_name.result
      ipv4 = hcloud_server.suse-arm-caddy.ipv4_address
      ipv6 = hcloud_server.suse-arm-caddy.ipv6_address
    }
    suse_arm_nginx = {
      name = random_string.suse_arm_nginx_dns_name.result
      ipv4 = hcloud_server.suse-arm-nginx.ipv4_address
      ipv6 = hcloud_server.suse-arm-nginx.ipv6_address
    }
    suse_x86_apache = {
      name = random_string.suse_x86_apache_dns_name.result
      ipv4 = hcloud_server.suse-x86-apache.ipv4_address
      ipv6 = hcloud_server.suse-x86-apache.ipv6_address
    }
    suse_x86_caddy = {
      name = random_string.suse_x86_caddy_dns_name.result
      ipv4 = hcloud_server.suse-x86-caddy.ipv4_address
      ipv6 = hcloud_server.suse-x86-caddy.ipv6_address
    }
    suse_x86_nginx = {
      name = random_string.suse_x86_nginx_dns_name.result
      ipv4 = hcloud_server.suse-x86-nginx.ipv4_address
      ipv6 = hcloud_server.suse-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "suse_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.suse_dns_records : [
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