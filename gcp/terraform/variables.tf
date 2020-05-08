#########################################
# Variables file for GCP Provisioning
#########################################

variable "organization" {
  default = "valien-personal"
}

variable "workspace" {
  default = "foundryvtt"
}

variable "prefix" {
  description = "Prefix for resources"
  default = "foundry-vtt"
}

# us-east1 - zone b, c, d
# us-east4 - zone a, b, c
variable "region" {
    #type = list(string)
    description = "GCP region to launch server"
    default     = "us-east1"
}

variable "zone" {
  description = "GCP Zone to use"
  default     = "us-east1-d"
}

# This will prompt you for your GCP project. If you have one to enter you can set the variable so that it always pick this one.
variable "project" {
  description = "GCP Project ID"
  default     = ""
}

variable "instance_name" {
    default = "foundry-vtt"
}

variable "address_space" {
  description = "Address space for the VPC"
  default = "10.10.0.0/16"
}

variable "subnet_prefix" {
  description = "Address prefix for subnet."
  default = "10.10.10.0/24"
}

# GCP calls them machine types vs AWS instance types
# https://cloud.google.com/compute/docs/machine-types
# f1-micro works for GCP free credits. If you need a larger machine type then adjust this.
variable "machine_type" {
  default = "f1-micro"
 }

# https://www.terraform.io/docs/providers/google/r/compute_instance.html#boot_disk
variable "image" {
  description = "type of OS image to use"
  default     = "ubuntu-1910-eoan-v20200413a" # not working for some reason: "ubuntu-os-cloud/ubuntu-1910-lts"
}

# @TODO:
# the below zone id is for chumpmonkey.com TLD
# variable "route53_zone_id" {
#   description = "Zone ID for f8flabs.com "
#   default = ""
# }

 variable "dns_hostname" {
  default = "foundry.chumpmonkey.com"
 }

variable "ssh_user" {
  default = "ubuntu"
}
