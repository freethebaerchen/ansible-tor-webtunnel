variable "server_config" {
  description = "Configuration for the test server"
  type = object({
    name               = string
    os                 = string
    arch               = string
    webserver          = string
    image              = string
    server_type        = string
    location           = string
    firewall_ids       = list(string)
    placement_group_id = string
    user_data          = optional(string)
  })
}

variable "dns_zone_id" {
  description = "CloudFlare DNS Zone ID"
  type        = string
}