# Manual prerequisite (once): point your domain's nameservers
# at Registro.br to the Cloudflare NS. After that, everything is code.

locals {
  zone = var.zone
  lab  = "${var.lab_subdomain}.${var.zone}"
}

# --- private: resolves to the Tailscale IP; only tailnet members can reach it ---
resource "cloudflare_dns_record" "lab" {
  zone_id = var.zone_id
  name    = local.lab
  type    = "A"
  content = var.vps_tailscale_ip
  ttl     = 300
  proxied = false
}

resource "cloudflare_dns_record" "lab_wildcard" {
  zone_id = var.zone_id
  name    = "*.${local.lab}" # signoz.lab, argocd.lab, ...
  type    = "A"
  content = var.vps_tailscale_ip
  ttl     = 300
  proxied = false
}

# Nothing public. Everything is *.lab → Tailscale. No proxy, no raw IP.
