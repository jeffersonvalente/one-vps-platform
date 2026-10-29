terraform {
  required_version = ">= 1.6"
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.17"
    }
  }
}

provider "tailscale" {
  # OAuth client via env TAILSCALE_OAUTH_CLIENT_ID / TAILSCALE_OAUTH_CLIENT_SECRET
  # (admin console → Settings → OAuth clients, scopes: devices, policy_file, auth_keys)
}
