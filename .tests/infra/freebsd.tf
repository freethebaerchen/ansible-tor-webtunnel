## Setup FreeBSD Arm64-Servers
resource "hcloud_server" "freebsd-arm-apache" {
  name               = "freebsd-arm-apache"
  image              = data.hcloud_image.freebsd_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_arm_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "arm"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "freebsd-arm-caddy" {
  name               = "freebsd-arm-caddy"
  image              = data.hcloud_image.freebsd_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_arm_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "arm"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "freebsd-arm-nginx" {
  name               = "freebsd-arm-nginx"
  image              = data.hcloud_image.freebsd_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_arm_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "arm"
    "webserver" = "nginx"
  }
}

## Setup FreeBSD x86_64-Servers
resource "hcloud_server" "freebsd-x86-apache" {
  name               = "freebsd-x86-apache"
  image              = data.hcloud_image.freebsd_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_x86_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "freebsd-x86-caddy" {
  name               = "freebsd-x86-caddy"
  image              = data.hcloud_image.freebsd_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_x86_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "freebsd-x86-nginx" {
  name               = "freebsd-x86-nginx"
  image              = data.hcloud_image.freebsd_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.freebsd_x86_snapshot
  ]
  labels = {
    "os"        = "freebsd"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for freebsd-arm-apache DNS records
resource "random_string" "freebsd_arm_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for freebsd-arm-caddy DNS records
resource "random_string" "freebsd_arm_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for freebsd-arm-nginx DNS records
resource "random_string" "freebsd_arm_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for freebsd-x86-apache DNS records
resource "random_string" "freebsd_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for freebsd-x86-caddy DNS records
resource "random_string" "freebsd_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for freebsd-x86-nginx DNS records
resource "random_string" "freebsd_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  freebsd_dns_records = {
    freebsd_arm_apache = {
      name = random_string.freebsd_arm_apache_dns_name.result
      ipv4 = hcloud_server.freebsd-arm-apache.ipv4_address
      ipv6 = hcloud_server.freebsd-arm-apache.ipv6_address
    }
    freebsd_arm_caddy = {
      name = random_string.freebsd_arm_caddy_dns_name.result
      ipv4 = hcloud_server.freebsd-arm-caddy.ipv4_address
      ipv6 = hcloud_server.freebsd-arm-caddy.ipv6_address
    }
    freebsd_arm_nginx = {
      name = random_string.freebsd_arm_nginx_dns_name.result
      ipv4 = hcloud_server.freebsd-arm-nginx.ipv4_address
      ipv6 = hcloud_server.freebsd-arm-nginx.ipv6_address
    }
    freebsd_x86_apache = {
      name = random_string.freebsd_x86_apache_dns_name.result
      ipv4 = hcloud_server.freebsd-x86-apache.ipv4_address
      ipv6 = hcloud_server.freebsd-x86-apache.ipv6_address
    }
    freebsd_x86_caddy = {
      name = random_string.freebsd_x86_caddy_dns_name.result
      ipv4 = hcloud_server.freebsd-x86-caddy.ipv4_address
      ipv6 = hcloud_server.freebsd-x86-caddy.ipv6_address
    }
    freebsd_x86_nginx = {
      name = random_string.freebsd_x86_nginx_dns_name.result
      ipv4 = hcloud_server.freebsd-x86-nginx.ipv4_address
      ipv6 = hcloud_server.freebsd-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "freebsd_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.freebsd_dns_records : [
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