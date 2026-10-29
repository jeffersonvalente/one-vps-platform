variable "zone" {
  description = "Your apex domain managed in Cloudflare, e.g. example.com."
  type        = string
}

variable "lab_subdomain" {
  description = "Subdomain under the zone for private hosts (lab.<zone> and *.lab.<zone>)."
  type        = string
  default     = "lab"
}

variable "zone_id" {
  description = "Zone ID of the domain (Cloudflare dashboard → Overview → API)."
  type        = string
}

variable "vps_tailscale_ip" {
  description = "100.x IP of the VPS on the tailnet (after Phase 2)."
  type        = string
}
