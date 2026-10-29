variable "region" {
  type    = string
  default = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "Compartment where the bucket will live (can be the tenancy root)."
  type        = string
}
