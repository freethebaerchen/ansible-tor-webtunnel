## Backend configuration
terraform {
  backend "s3" {
    bucket                      = "ansible-tor-webtunnel-testing-terraform-state"
    key                         = "terraform.tfstate"
    region                      = "main"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    use_lockfile                = true
  }
}

## SSH-Key
resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = file("~/.ssh/id_ed25519.pub")
}

## Firewall for testing
resource "hcloud_firewall" "allow_testing" {
  name = "firewall-allow-testing"

  rule {
    description = "http"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "https"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "ssh"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

data "hcloud_image" "alpine_arm_snapshot" {
  with_selector     = "os=alpine"
  with_architecture = "arm"
  most_recent       = true
}

data "hcloud_image" "alpine_x86_snapshot" {
  with_selector     = "os=alpine"
  with_architecture = "x86"
  most_recent       = true
}

data "hcloud_image" "freebsd_arm_snapshot" {
  with_selector     = "os=freebsd"
  with_architecture = "arm"
  most_recent       = true
}

data "hcloud_image" "freebsd_x86_snapshot" {
  with_selector     = "os=freebsd"
  with_architecture = "x86"
  most_recent       = true
}

data "hcloud_image" "openbsd_arm_snapshot" {
  with_selector     = "os=openbsd"
  with_architecture = "arm"
  most_recent       = true
}

data "hcloud_image" "openbsd_x86_snapshot" {
  with_selector     = "os=openbsd"
  with_architecture = "x86"
  most_recent       = true
}

data "hcloud_image" "archlinux_x86_snapshot" {
  with_selector     = "os=archlinux"
  with_architecture = "x86"
  most_recent       = true
}

# Test server configurations - single source of truth
locals {
  test_servers = {
    # Alpine servers
    "alpine-arm-apache" = {
      os          = "alpine"
      webserver   = "apache"
      arch        = "arm"
      image       = data.hcloud_image.alpine_arm_snapshot.id
      server_type = var.arm_small
    }
    "alpine-arm-caddy" = {
      os          = "alpine"
      webserver   = "caddy"
      arch        = "arm"
      image       = data.hcloud_image.alpine_arm_snapshot.id
      server_type = var.arm_small
    }
    "alpine-arm-nginx" = {
      os          = "alpine"
      webserver   = "nginx"
      arch        = "arm"
      image       = data.hcloud_image.alpine_arm_snapshot.id
      server_type = var.arm_small
    }
    "alpine-arm-docker" = {
      os          = "alpine"
      webserver   = "docker"
      arch        = "arm"
      image       = data.hcloud_image.alpine_arm_snapshot.id
      server_type = var.arm_small
    }
    "alpine-x86-apache" = {
      os          = "alpine"
      webserver   = "apache"
      arch        = "x86_64"
      image       = data.hcloud_image.alpine_x86_snapshot.id
      server_type = var.x86_small
    }
    "alpine-x86-caddy" = {
      os          = "alpine"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = data.hcloud_image.alpine_x86_snapshot.id
      server_type = var.x86_small
    }
    "alpine-x86-nginx" = {
      os          = "alpine"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = data.hcloud_image.alpine_x86_snapshot.id
      server_type = var.x86_small
    }
    "alpine-x86-docker" = {
      os          = "alpine"
      webserver   = "docker"
      arch        = "x86_64"
      image       = data.hcloud_image.alpine_x86_snapshot.id
      server_type = var.x86_small
    }
    # Archlinux servers
    "archlinux-x86-apache" = {
      os          = "archlinux"
      webserver   = "apache"
      arch        = "x86_64"
      image       = data.hcloud_image.archlinux_x86_snapshot.id
      server_type = var.x86_small
    }
    "archlinux-x86-caddy" = {
      os          = "archlinux"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = data.hcloud_image.archlinux_x86_snapshot.id
      server_type = var.x86_small
    }
    "archlinux-x86-nginx" = {
      os          = "archlinux"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = data.hcloud_image.archlinux_x86_snapshot.id
      server_type = var.x86_small
    }
    # FreeBSD servers
    "freebsd-arm-apache" = {
      os          = "freebsd"
      webserver   = "apache"
      arch        = "arm"
      image       = data.hcloud_image.freebsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "freebsd-arm-caddy" = {
      os          = "freebsd"
      webserver   = "caddy"
      arch        = "arm"
      image       = data.hcloud_image.freebsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "freebsd-arm-nginx" = {
      os          = "freebsd"
      webserver   = "nginx"
      arch        = "arm"
      image       = data.hcloud_image.freebsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "freebsd-x86-apache" = {
      os          = "freebsd"
      webserver   = "apache"
      arch        = "x86_64"
      image       = data.hcloud_image.freebsd_x86_snapshot.id
      server_type = var.x86_small
    }
    "freebsd-x86-caddy" = {
      os          = "freebsd"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = data.hcloud_image.freebsd_x86_snapshot.id
      server_type = var.x86_small
    }
    "freebsd-x86-nginx" = {
      os          = "freebsd"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = data.hcloud_image.freebsd_x86_snapshot.id
      server_type = var.x86_small
    }
    # OpenBSD servers
    "openbsd-arm-apache" = {
      os          = "openbsd"
      webserver   = "apache"
      arch        = "arm"
      image       = data.hcloud_image.openbsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "openbsd-arm-caddy" = {
      os          = "openbsd"
      webserver   = "caddy"
      arch        = "arm"
      image       = data.hcloud_image.openbsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "openbsd-arm-nginx" = {
      os          = "openbsd"
      webserver   = "nginx"
      arch        = "arm"
      image       = data.hcloud_image.openbsd_arm_snapshot.id
      server_type = var.arm_small
    }
    "openbsd-x86-apache" = {
      os          = "openbsd"
      webserver   = "apache"
      arch        = "x86_64"
      image       = data.hcloud_image.openbsd_x86_snapshot.id
      server_type = var.x86_small
    }
    "openbsd-x86-caddy" = {
      os          = "openbsd"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = data.hcloud_image.openbsd_x86_snapshot.id
      server_type = var.x86_small
    }
    "openbsd-x86-nginx" = {
      os          = "openbsd"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = data.hcloud_image.openbsd_x86_snapshot.id
      server_type = var.x86_small
    }
    # AlmaLinux servers
    "rhel-arm-apache" = {
      os          = "rhel"
      webserver   = "apache"
      arch        = "arm"
      image       = "alma-10"
      server_type = var.arm_small
    }
    "rhel-arm-caddy" = {
      os          = "rhel"
      webserver   = "caddy"
      arch        = "arm"
      image       = "alma-10"
      server_type = var.arm_small
    }
    "rhel-arm-nginx" = {
      os          = "rhel"
      webserver   = "nginx"
      arch        = "arm"
      image       = "alma-10"
      server_type = var.arm_small
    }
    "rhel-x86-apache" = {
      os          = "rhel"
      webserver   = "apache"
      arch        = "x86_64"
      image       = "alma-10"
      server_type = var.x86_small
    }
    "rhel-x86-caddy" = {
      os          = "rhel"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = "alma-10"
      server_type = var.x86_small
    }
    "rhel-x86-nginx" = {
      os          = "rhel"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = "alma-10"
      server_type = var.x86_small
    }
    # OpenSUSE Leap servers
    "suse-arm-apache" = {
      os          = "suse"
      webserver   = "apache"
      arch        = "arm"
      image       = "opensuse-15"
      server_type = var.arm_small
    }
    "suse-arm-caddy" = {
      os          = "suse"
      webserver   = "caddy"
      arch        = "arm"
      image       = "opensuse-15"
      server_type = var.arm_small
    }
    "suse-arm-nginx" = {
      os          = "suse"
      webserver   = "nginx"
      arch        = "arm"
      image       = "opensuse-15"
      server_type = var.arm_small
    }
    "suse-x86-apache" = {
      os          = "suse"
      webserver   = "apache"
      arch        = "x86_64"
      image       = "opensuse-15"
      server_type = var.x86_small
    }
    "suse-x86-caddy" = {
      os          = "suse"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = "opensuse-15"
      server_type = var.x86_small
    }
    "suse-x86-nginx" = {
      os          = "suse"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = "opensuse-15"
      server_type = var.x86_small
    }
    # Ubuntu servers
    "ubuntu-arm-apache" = {
      os          = "ubuntu"
      webserver   = "apache"
      arch        = "arm"
      image       = "ubuntu-24.04"
      server_type = var.arm_small
    }
    "ubuntu-arm-caddy" = {
      os          = "ubuntu"
      webserver   = "caddy"
      arch        = "arm"
      image       = "ubuntu-24.04"
      server_type = var.arm_small
    }
    "ubuntu-arm-nginx" = {
      os          = "ubuntu"
      webserver   = "nginx"
      arch        = "arm"
      image       = "ubuntu-24.04"
      server_type = var.arm_small
    }
    "ubuntu-arm-docker" = {
      os          = "ubuntu"
      webserver   = "docker"
      arch        = "arm"
      image       = "ubuntu-24.04"
      server_type = var.arm_small
    }
    "ubuntu-x86-apache" = {
      os          = "ubuntu"
      webserver   = "apache"
      arch        = "x86_64"
      image       = "ubuntu-24.04"
      server_type = var.x86_small
    }
    "ubuntu-x86-caddy" = {
      os          = "ubuntu"
      webserver   = "caddy"
      arch        = "x86_64"
      image       = "ubuntu-24.04"
      server_type = var.x86_small
    }
    "ubuntu-x86-nginx" = {
      os          = "ubuntu"
      webserver   = "nginx"
      arch        = "x86_64"
      image       = "ubuntu-24.04"
      server_type = var.x86_small
    }
    "ubuntu-x86-docker" = {
      os          = "ubuntu"
      webserver   = "docker"
      arch        = "x86_64"
      image       = "ubuntu-24.04"
      server_type = var.x86_small
    }
  }
}

## Create all test servers using the module
module "test_servers" {
  source = "./modules/test-server"

  for_each = local.test_servers

  server_config = {
    name               = each.key
    os                 = each.value.os
    arch               = each.value.arch
    webserver          = each.value.webserver
    image              = each.value.image
    server_type        = each.value.server_type
    location           = var.location
    ssh_keys           = [hcloud_ssh_key.default.id]
    firewall_ids       = [hcloud_firewall.allow_testing.id]
    placement_group_id = var.placement_group_id
    user_data          = lookup(each.value, "user_data", null)
  }

  dns_zone_id = var.dns_zone_id
}