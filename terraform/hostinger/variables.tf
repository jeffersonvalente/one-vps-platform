variable "vps_id" {
  description = "VPS ID in hPanel (used only to document the import)."
  type        = number
}

variable "hostname" {
  type    = string
  default = "vps.lab.example.com"
}

variable "ssh_public_key" {
  description = "Admin ed25519 public key (contents of the .pub)."
  type        = string
}
