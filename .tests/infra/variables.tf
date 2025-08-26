variable "arm_small" {
  description = "Small instances type with Arm64 processor in Hetzner Cloud"
  type        = string
  default     = "cax11"
}

variable "x86_small" {
  description = "Small instances type with x86 processor in Hetzner Cloud"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "Hetzner Cloud location."
  type        = string
  default     = "fsn1"
}

variable "dns_zone_id" {
  description = "CloudFlare DNS Zone ID"
  type        = string
  default     = null
}