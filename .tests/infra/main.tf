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
  with_selector = "os=alpine,architecture=arm"
  most_recent   = true
}

data "hcloud_image" "alpine_x86_snapshot" {
  with_selector = "os=alpine,architecture=x86"
  most_recent   = true
}

data "hcloud_image" "freebsd_arm_snapshot" {
  with_selector = "os=freebsd,architecture=arm"
  most_recent   = true
}

data "hcloud_image" "freebsd_x86_snapshot" {
  with_selector = "os=freebsd,architecture=x86"
  most_recent   = true
}

data "hcloud_image" "openbsd_arm_snapshot" {
  with_selector = "os=openbsd,architecture=arm"
  most_recent   = true
}

data "hcloud_image" "openbsd_x86_snapshot" {
  with_selector = "os=openbsd,architecture=x86"
  most_recent   = true
}

data "hcloud_image" "archlinux_x86_snapshot" {
  with_selector = "os=archlinux,architecture=x86"
  most_recent   = true
}
