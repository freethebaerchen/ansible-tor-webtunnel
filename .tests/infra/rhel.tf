## Setup AlmaLinux Arm64-Servers
resource "hcloud_server" "rhel-arm-apache" {
  name         = "rhel-arm-apache"
  image        = "alma-10"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "arm"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "rhel-arm-caddy" {
  name         = "rhel-arm-caddy"
  image        = "alma-10"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "arm"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "rhel-arm-nginx" {
  name         = "rhel-arm-nginx"
  image        = "alma-10"
  server_type  = var.arm_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "arm"
    "webserver" = "nginx"
  }
}

## Setup AlmaLinux x86_64-Servers
resource "hcloud_server" "rhel-x86-apache" {
  name         = "rhel-x86-apache"
  image        = "alma-10"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "rhel-x86-caddy" {
  name         = "rhel-x86-caddy"
  image        = "alma-10"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "rhel-x86-nginx" {
  name         = "rhel-x86-nginx"
  image        = "alma-10"
  server_type  = var.x86_small
  location     = var.location
  firewall_ids = [hcloud_firewall.allow_testing.id]
  backups      = false
  keep_disk    = false
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "almalinux"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for rhel-arm-apache DNS records
resource "random_string" "rhel_arm_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for rhel-arm-caddy DNS records
resource "random_string" "rhel_arm_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for rhel-arm-nginx DNS records
resource "random_string" "rhel_arm_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for rhel-x86-apache DNS records
resource "random_string" "rhel_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for rhel-x86-caddy DNS records
resource "random_string" "rhel_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for rhel-x86-nginx DNS records
resource "random_string" "rhel_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  rhel_dns_records = {
    rhel_arm_apache = {
      name = random_string.rhel_arm_apache_dns_name.result
      ipv4 = hcloud_server.rhel-arm-apache.ipv4_address
      ipv6 = hcloud_server.rhel-arm-apache.ipv6_address
    }
    rhel_arm_caddy = {
      name = random_string.rhel_arm_caddy_dns_name.result
      ipv4 = hcloud_server.rhel-arm-caddy.ipv4_address
      ipv6 = hcloud_server.rhel-arm-caddy.ipv6_address
    }
    rhel_arm_nginx = {
      name = random_string.rhel_arm_nginx_dns_name.result
      ipv4 = hcloud_server.rhel-arm-nginx.ipv4_address
      ipv6 = hcloud_server.rhel-arm-nginx.ipv6_address
    }
    rhel_x86_apache = {
      name = random_string.rhel_x86_apache_dns_name.result
      ipv4 = hcloud_server.rhel-x86-apache.ipv4_address
      ipv6 = hcloud_server.rhel-x86-apache.ipv6_address
    }
    rhel_x86_caddy = {
      name = random_string.rhel_x86_caddy_dns_name.result
      ipv4 = hcloud_server.rhel-x86-caddy.ipv4_address
      ipv6 = hcloud_server.rhel-x86-caddy.ipv6_address
    }
    rhel_x86_nginx = {
      name = random_string.rhel_x86_nginx_dns_name.result
      ipv4 = hcloud_server.rhel-x86-nginx.ipv4_address
      ipv6 = hcloud_server.rhel-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "rhel_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.rhel_dns_records : [
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