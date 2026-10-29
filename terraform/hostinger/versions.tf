terraform {
  required_version = ">= 1.6"

  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 0.1"
    }
  }

  # Local state for now. Once the OCI bucket exists, move to S3-compatible:
  # backend "s3" { bucket = "onevps-tfstate" key = "hostinger.tfstate" ... }
}

provider "hostinger" {
  # api_token via env HOSTINGER_API_TOKEN
}
