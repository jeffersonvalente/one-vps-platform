# Manual prerequisite (once): point the example.com nameservers
# at Registro.br to the Cloudflare NS. After that, everything is code.

locals {
  zone = "example.com"
}

# --- private: resolves to the Tailscale IP; only tailnet members can reach it ---
resource "cloudflare_dns_record" "lab" {
  zone_id = var.zone_id
  name    = "lab.${local.zone}"
  type    = "A"
  content = var.vps_tailscale_ip
  ttl     = 300
  proxied = false
}

resource "cloudflare_dns_record" "lab_wildcard" {
  zone_id = var.zone_id
  name    = "*.lab.${local.zone}" # signoz.lab, argocd.lab, ...
  type    = "A"
  content = var.vps_tailscale_ip
  ttl     = 300
  proxied = false
}

# Nothing public. Everything is *.lab → Tailscale. No proxy, no raw IP.
