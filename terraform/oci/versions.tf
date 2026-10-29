terraform {
  required_version = ">= 1.6"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  # Uses ~/.oci/config (profile DEFAULT) — same config as oci-cli.
  region = var.region
}
