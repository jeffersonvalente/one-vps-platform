# Always Free: 20 GB of Object Storage. restic destination.

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "backup" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "onevps-backup"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = "Disabled" # restic already versions; saves the free tier

  freeform_tags = { project = "one-vps-platform", managed-by = "terraform" }
}

# restic talks S3 to OCI via a "Customer Secret Key":
#   oci iam customer-secret-key create --user-id <ocid> --display-name restic
# Endpoint: https://<namespace>.compat.objectstorage.sa-saopaulo-1.oraclecloud.com
output "restic_repository" {
  value = "s3:https://${data.oci_objectstorage_namespace.ns.namespace}.compat.objectstorage.${var.region}.oraclecloud.com/${oci_objectstorage_bucket.backup.name}"
}
