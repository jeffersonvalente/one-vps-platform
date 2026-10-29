output "vps_id" {
  value = hostinger_vps.lab.id
}

output "ipv4" {
  value       = try(hostinger_vps.lab.ipv4_address, null)
  description = "Public IP — only for bootstrap SSH (phase 1-2)."
}
