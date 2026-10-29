variable "region" {
  type    = string
  default = "sa-saopaulo-1"
}

variable "bucket_name" {
  description = "Object Storage bucket for restic backups."
  type        = string
  default     = "onevps-backup"
}

variable "compartment_ocid" {
  description = "Compartment where the bucket will live (can be the tenancy root)."
  type        = string
}
