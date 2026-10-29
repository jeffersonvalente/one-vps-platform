# Tailnet ACL: who talks to what.
resource "tailscale_acl" "policy" {
  acl = file("${path.module}/acl.hujson")
  # the console policy was hand-edited once; the repo is the source of truth
  overwrite_existing_content = true
}

# Reusable auth key for Ansible to register the VPS (tag:server).
# Encrypt the output before storing it: terraform output -raw server_authkey | sops ...
resource "tailscale_tailnet_key" "server" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000 # 90 days, renew
  tags          = ["tag:server"]
  description   = "ansible tailscale lab vps"
}

output "server_authkey" {
  value     = tailscale_tailnet_key.server.key
  sensitive = true
}
