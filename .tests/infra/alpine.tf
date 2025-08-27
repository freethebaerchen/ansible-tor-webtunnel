
## Setup Alpine Arm64-Servers
resource "hcloud_server" "alpine-arm-apache" {
  name               = "alpine-arm-apache"
  image              = data.hcloud_image.alpine_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_arm_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "arm"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "alpine-arm-caddy" {
  name               = "alpine-arm-caddy"
  image              = data.hcloud_image.alpine_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_arm_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "arm"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "alpine-arm-nginx" {
  name               = "alpine-arm-nginx"
  image              = data.hcloud_image.alpine_arm_snapshot.id
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_arm_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "arm"
    "webserver" = "nginx"
  }
}

## Setup Alpine x86_64-Servers
resource "hcloud_server" "alpine-x86-apache" {
  name               = "alpine-x86-apache"
  image              = data.hcloud_image.alpine_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_x86_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "alpine-x86-caddy" {
  name               = "alpine-x86-caddy"
  image              = data.hcloud_image.alpine_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_x86_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "alpine-x86-nginx" {
  name               = "alpine-x86-nginx"
  image              = data.hcloud_image.alpine_x86_snapshot.id
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  depends_on = [
    hcloud_firewall.allow_testing,
    data.hcloud_image.alpine_x86_snapshot
  ]
  labels = {
    "os"        = "alpine"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for alpine-arm-apache DNS records
resource "random_string" "alpine_arm_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for alpine-arm-caddy DNS records
resource "random_string" "alpine_arm_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for alpine-arm-nginx DNS records
resource "random_string" "alpine_arm_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for alpine-x86-apache DNS records
resource "random_string" "alpine_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for alpine-x86-caddy DNS records
resource "random_string" "alpine_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for alpine-x86-nginx DNS records
resource "random_string" "alpine_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  alpine_dns_records = {
    alpine_arm_apache = {
      name = random_string.alpine_arm_apache_dns_name.result
      ipv4 = hcloud_server.alpine-arm-apache.ipv4_address
      ipv6 = hcloud_server.alpine-arm-apache.ipv6_address
    }
    alpine_arm_caddy = {
      name = random_string.alpine_arm_caddy_dns_name.result
      ipv4 = hcloud_server.alpine-arm-caddy.ipv4_address
      ipv6 = hcloud_server.alpine-arm-caddy.ipv6_address
    }
    alpine_arm_nginx = {
      name = random_string.alpine_arm_nginx_dns_name.result
      ipv4 = hcloud_server.alpine-arm-nginx.ipv4_address
      ipv6 = hcloud_server.alpine-arm-nginx.ipv6_address
    }
    alpine_x86_apache = {
      name = random_string.alpine_x86_apache_dns_name.result
      ipv4 = hcloud_server.alpine-x86-apache.ipv4_address
      ipv6 = hcloud_server.alpine-x86-apache.ipv6_address
    }
    alpine_x86_caddy = {
      name = random_string.alpine_x86_caddy_dns_name.result
      ipv4 = hcloud_server.alpine-x86-caddy.ipv4_address
      ipv6 = hcloud_server.alpine-x86-caddy.ipv6_address
    }
    alpine_x86_nginx = {
      name = random_string.alpine_x86_nginx_dns_name.result
      ipv4 = hcloud_server.alpine-x86-nginx.ipv4_address
      ipv6 = hcloud_server.alpine-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "alpine_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.alpine_dns_records : [
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