## Setup Ubuntu Arm64-Servers
resource "hcloud_server" "ubuntu-arm-apache" {
  name               = "ubuntu-arm-apache"
  image              = "ubuntu-24.04"
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "arm"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "ubuntu-arm-caddy" {
  name               = "ubuntu-arm-caddy"
  image              = "ubuntu-24.04"
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "arm"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "ubuntu-arm-nginx" {
  name               = "ubuntu-arm-nginx"
  image              = "ubuntu-24.04"
  server_type        = var.arm_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "arm"
    "webserver" = "nginx"
  }
}

## Setup Ubuntu x86_64-Servers
resource "hcloud_server" "ubuntu-x86-apache" {
  name               = "ubuntu-x86-apache"
  image              = "ubuntu-24.04"
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "x86_64"
    "webserver" = "apache"
  }
}

resource "hcloud_server" "ubuntu-x86-caddy" {
  name               = "ubuntu-x86-caddy"
  image              = "ubuntu-24.04"
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "x86_64"
    "webserver" = "caddy"
  }
}

resource "hcloud_server" "ubuntu-x86-nginx" {
  name               = "ubuntu-x86-nginx"
  image              = "ubuntu-24.04"
  server_type        = var.x86_small
  location           = var.location
  firewall_ids       = [hcloud_firewall.allow_testing.id]
  backups            = false
  keep_disk          = false
  placement_group_id = var.placement_group_id
  user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    root_group = "root"
  })
  depends_on = [
    hcloud_firewall.allow_testing
  ]
  labels = {
    "os"        = "ubuntu"
    "arch"      = "x86_64"
    "webserver" = "nginx"
  }
}

# Random string for ubuntu-arm-apache DNS records
resource "random_string" "ubuntu_arm_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for ubuntu-arm-caddy DNS records
resource "random_string" "ubuntu_arm_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for ubuntu-arm-nginx DNS records
resource "random_string" "ubuntu_arm_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for ubuntu-x86-apache DNS records
resource "random_string" "ubuntu_x86_apache_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for ubuntu-x86-caddy DNS records
resource "random_string" "ubuntu_x86_caddy_dns_name" {
  length  = 8
  special = false
  upper   = false
}

# Random string for ubuntu-x86-nginx DNS records
resource "random_string" "ubuntu_x86_nginx_dns_name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  ubuntu_dns_records = {
    ubuntu_arm_apache = {
      name = random_string.ubuntu_arm_apache_dns_name.result
      ipv4 = hcloud_server.ubuntu-arm-apache.ipv4_address
      ipv6 = hcloud_server.ubuntu-arm-apache.ipv6_address
    }
    ubuntu_arm_caddy = {
      name = random_string.ubuntu_arm_caddy_dns_name.result
      ipv4 = hcloud_server.ubuntu-arm-caddy.ipv4_address
      ipv6 = hcloud_server.ubuntu-arm-caddy.ipv6_address
    }
    ubuntu_arm_nginx = {
      name = random_string.ubuntu_arm_nginx_dns_name.result
      ipv4 = hcloud_server.ubuntu-arm-nginx.ipv4_address
      ipv6 = hcloud_server.ubuntu-arm-nginx.ipv6_address
    }
    ubuntu_x86_apache = {
      name = random_string.ubuntu_x86_apache_dns_name.result
      ipv4 = hcloud_server.ubuntu-x86-apache.ipv4_address
      ipv6 = hcloud_server.ubuntu-x86-apache.ipv6_address
    }
    ubuntu_x86_caddy = {
      name = random_string.ubuntu_x86_caddy_dns_name.result
      ipv4 = hcloud_server.ubuntu-x86-caddy.ipv4_address
      ipv6 = hcloud_server.ubuntu-x86-caddy.ipv6_address
    }
    ubuntu_x86_nginx = {
      name = random_string.ubuntu_x86_nginx_dns_name.result
      ipv4 = hcloud_server.ubuntu-x86-nginx.ipv4_address
      ipv6 = hcloud_server.ubuntu-x86-nginx.ipv6_address
    }
  }
}

# Create DNS records for each server
resource "cloudflare_dns_record" "ubuntu_dns_records" {
  for_each = {
    for pair in flatten([
      for server_name, server_data in local.ubuntu_dns_records : [
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