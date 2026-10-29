variable "zone_id" {
  description = "Zone ID of example.com (Cloudflare dashboard → Overview)."
  type        = string
}

variable "vps_tailscale_ip" {
  description = "100.x IP of the VPS on the tailnet (after Phase 2)."
  type        = string
}
