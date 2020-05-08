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

# @TODO: Split up rules - SSH from home IP only. Add Foundry rule - 30000, seperate http/https rule - 80/443
# Remove default-allow-rdp, default-allow-ssh? (check network)
resource "google_compute_firewall" "terraform-gcp" {
  name = "default-allow-ssh-http"
  network = google_compute_network.terraform-gcp.self_link

# Port 30000 for default Foundry VTT. Adjust as necessary.
  allow {
    protocol = "tcp"
    ports = ["22", "80", "443", "30000"]
  }

  # @TODO: set for home IP only for SSH
  # currently allows traffic from everyone to instances with http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["foundry-server"]

}

# creating key pair for each instance
# do not use this for prod - https://www.terraform.io/docs/providers/tls/r/private_key.html
# good for testing only
resource "tls_private_key" "terraform-gcp" {
  algorithm = "RSA"
  rsa_bits = "4096"
}

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

  metadata = {
    ssh-keys = "foundry:${chomp(tls_private_key.terraform-gcp.public_key_openssh)} terraform"
  }

  tags = ["foundry-server"]
}

output "ip" {
  value = "${google_compute_instance.terraform-gcp.network_interface.0.access_config.0.nat_ip}"
}


# set Route 53 DNS
# resource "aws_route53_record" "terraform-dns" {
#   zone_id = var.route53_zone_id
#   name    = var.dns_hostname
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_eip.terraform-aws.public_ip}"]
# }

# generate a temp key for this instance
# do not use this for prod - https://www.terraform.io/docs/providers/tls/r/private_key.html
# good for testing only
# resource "tls_private_key" "terraform-aws" {
#   algorithm = "RSA"
# }

# creates usable local var
# https://www.terraform.io/docs/configuration/locals.html
# locals {
#   private_key_filename = "${var.prefix}-ssh-key.pem"
# }


# obtain current external IP address for SSH Ingress
# thanks to this post - https://letslearndevops.com/2018/09/24/getting-own-ip/
# data "external" "terraform-gcp" {
#   program = ["bash", "-c", "curl 'https://ipinfo.io/json'"]
# }

# output "current_public_ip" {
#   value = data.external.terraform-aws.result.ip
# }

# checking server status before firing off Ansible playbook.
# resource "null_resource" "terraform-gcp" {
#   provisioner "remote-exec" {
#     inline = ["echo 'The server is up.'"]

#     connection {
#       type        = "ssh"
#       user        = var.ssh_user
#       private_key = tls_private_key.terraform-gcp.private_key_pem
#       host        = gcp_compute_instance.terraform-gcp.network_interface.0.access_config.0.nat_ip
#     }
#   }
  # requires you to set .ansible.cfg host checking to False.
  # todo: call ansible playbook that will configure EC2 instance

  # # copying generated key to ~/.ssh folder and changing permissions so the following local-exec can execute.
  # provisioner "local-exec" {
  #   command = "echo '${tls_private_key.terraform-aws.private_key_pem}' > ~/.ssh/${local.private_key_filename}" #| chmod 0400 ~/.ssh/${local.private_key_filename}"
  # }

  # # somehow pipes is causing a file not found issue so splitting up commands
  # provisioner "local-exec" {
  #   command = "chmod 0400 ~/.ssh/${local.private_key_filename}"
  # }

  # running ansible playbook and/or ad-hoc commands
  # provisioner "local-exec" {
  #   command = "ansible all -i '${aws_eip.terraform-aws.public_ip},' -m ping -u ${var.ssh_user} --private-key=~/.ssh/${local.private_key_filename}"
  # }

  # output IP and DNS to ansible hosts file 2 directories up.
  # provisioner "local-exec" {
  #   command = "echo ${aws_eip.terraform-aws.public_ip} > ../../ansible/hosts"
  #   #command = "echo aws_eip.eip.public_dns > ../../ansible/hosts"
  # }

  # on destroy will also remove the ssh key from ~/.ssh
#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm -f ~/.ssh/${local.private_key_filename}"
#   }
#  }

# if you need to dump any data to the terminal

# output "ip" {
#   value = "${aws_eip.ip.public_ip}"
# }

# output "dns" {
#   value = "${aws_eip.dns.public_dns}"
# }

# output "public_ip" {
#   value = "${aws_instance.ansible-node.public_ip}"
# }

# output "public_dns" {
#   value = "${aws_instance.ansible-node.public_dns}"
# }