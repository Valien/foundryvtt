#########################################
# Main Terraform file for GCP Provisioning
#########################################

# storing terraform state on app.terraform.io
terraform {
  required_version = ">= 0.12"
  backend "remote" {
    organization = "valien-personal"
    workspaces {
      name = "foundryvtt"
    }
  }
}
  
# selecting GCP region
provider "google" {
  version = "~> 2.0"

  project = var.project
  region  = var.region
  zone    = var.zone

}

# setting minimum versions for providers
provider "random" {
  version = "~> 2.2"
}

provider "tls" {
  version = "~> 2.1"
}

provider "null" {
  version = "~> 2.1"
}

provider "external" {
  version = "~> 1.2"
}

# enables OS login from project perspectice. 
resource "google_compute_project_metadata" "terraform-gcp" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}

# creating network
resource "google_compute_network" "terraform-gcp" {
  name = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "terraform-gcp" {
  name = "${var.prefix}-subnet"
  region = var.region
  network = google_compute_network.terraform-gcp.self_link
  ip_cidr_range = var.subnet_prefix
}

# firewall rules for foundry access
resource "google_compute_firewall" "terraform-gcp-foundry" {
  name = "default-allow-foundry"
  network = google_compute_network.terraform-gcp.self_link

# Port 30000 for default Foundry VTT. Adjust as necessary.
  allow {
    protocol = "tcp"
    ports = ["80", "443", "30000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["foundry-server"]

}

# ssh from home ip only
resource "google_compute_firewall" "terraform-gcp-ssh" {
  name = "default-allow-foundry-ssh"
  network = google_compute_network.terraform-gcp.self_link

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  #source_ranges = ["${data.external.terraform-gcp.result.ip}/32"]
  source_ranges = ["${var.localip}/32"]
  target_tags = ["foundry-server"]

}

# creating key pair for each instance
# do not use this for prod - https://www.terraform.io/docs/providers/tls/r/private_key.html
# good for testing only
# resource "tls_private_key" "terraform-gcp" {
#   algorithm = "RSA"
#   rsa_bits = "4096"
# }

# locals {
#   private_key_filename = "${var.prefix}-ssh-key.pem"
# }

# create random ID for GCP instance
resource "random_id" "app-server-id" {
  #prefix      = "${var.prefix}-terraform-gcp-"
  byte_length = 8
}

resource "google_compute_instance" "terraform-gcp" {
  name = "${var.instance_name}-terraform-gcp-${random_id.app-server-id.hex}"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.terraform-gcp.self_link
    access_config {

    }
  }
  # Handle using OS Login - https://cloud.google.com/compute/docs/instances/managing-instance-access
  # metadata = {
  #   ssh-keys = "foundry:${chomp(tls_private_key.terraform-gcp.public_key_openssh)} terraform"
  # }

  tags = ["foundry-server"]
}

output "ip" {
  value = "${google_compute_instance.terraform-gcp.network_interface.0.access_config.0.nat_ip}"
}

# copy ssh key to local .ssh folder
# resource "null_resource" "terraform-gcp" {
#   # copying generated key to ~/.ssh folder and changing permissions so the following local-exec can execute.
#   provisioner "local-exec" {
#     command = "echo '${tls_private_key.terraform-gcp.private_key_pem}' > ~/.ssh/${local.private_key_filename}" 
#   }
  
#   provisioner "local-exec" {
#     command = "chmod 0400 ~/.ssh/${local.private_key_filename}"
#   }

#   # on destroy will also remove the ssh key from ~/.ssh
#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm -f ~/.ssh/${local.private_key_filename}"
#   }
# }

# obtain current external IP for SSH access
# does not work with remote backend as that pulls the Terraform IP and not your home IP
# data "external" "terraform-gcp" {
#   program = ["bash", "-c", "curl 'https://ipinfo.io/json'"]
# }