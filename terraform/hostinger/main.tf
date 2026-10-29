# ---------------------------------------------------------------------------
# Existing VPS, IMPORT, never create:
#   terraform import hostinger_vps.lab <VPS_ID>
#
# WARNING: in the Hostinger provider, `terraform destroy` on this resource
# CANCELS THE SUBSCRIPTION via the billing API. Hence prevent_destroy = true.
# To rebuild the machine: reinstall the OS (hPanel/API) and run Ansible.
# ---------------------------------------------------------------------------

resource "hostinger_vps_ssh_key" "ops" {
  name = "ops-ed25519"
  key  = var.ssh_public_key
}

resource "hostinger_vps" "lab" {
  # The attributes below are filled in by the import. After
  # `terraform state show hostinger_vps.lab`, copy plan/data_center_id/template_id
  # here so the plan stays clean.
  plan           = "hostingercom-vps-kvm4-usd-1m" # TODO: confirm from state after import
  data_center_id = 0                              # TODO: same (your region)
  template_id    = 0                              # TODO: same (Ubuntu 24.04)
  hostname       = var.hostname
  ssh_key_ids    = [hostinger_vps_ssh_key.ops.id]

  lifecycle {
    prevent_destroy = true
    # password is set in hPanel/reinstall; not managed here
    ignore_changes = [password]
  }
}

# Firewall: the provider does not expose firewall rules yet (check releases).
# Until then, rules are documented here and applied via hPanel or the API CLI (hapi):
#   - phase 0:  22/tcp  from 0.0.0.0/0  (temporary, bootstrap only)
#   - phase 2+: 22/tcp  REMOVE. Only 41641/udp remains (optional, direct
#              Tailscale connection instead of DERP relay). NOTHING else.
#              Internet sees: no TCP port. Intranet via tailnet.
