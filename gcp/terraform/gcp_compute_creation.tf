# selecting AWS region
provider "aws" {
  region = "${var.region}"
}

# creating VPC
resource "aws_vpc" "jsd-ansible-web-demo" {
  cidr_block            = "192.168.0.0/16"
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.vpc-name}"
  }
}

# creating IG
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.jsd-ansible-web-demo.id}"
}
# configure IG
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.jsd-ansible-web-demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.jsd-ansible-web-demo.id}"
  cidr_block              = "192.168.8.0/24"
  map_public_ip_on_launch = true
}

# create SG
resource "aws_security_group" "jsd-ansible-web-demo-sg" {
  name = "${var.sg-name}"
  description = "SG for SSH/HTTP access"
  vpc_id = "${aws_vpc.jsd-ansible-web-demo.id}"

  # SSH 
  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip}/32"]
  }

  # HTTP 
   ingress {
     description = "Web access"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

  # HTTPS 
   ingress {
     description = "Web access"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }


  # Outbound Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# set Route 53 DNS
resource "aws_route53_record" "ansible-dns" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.hostname}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ansible-node.public_ip}"]
}

resource "aws_instance" "ansible-node" {
  #name          = "${var.instance_name}"
  ami            = "${var.ami}"
  instance_type  = "${var.size}"
  key_name       = "${var.key}"
  
  
  vpc_security_group_ids = ["${aws_security_group.jsd-ansible-web-demo-sg.id}"]
  subnet_id = "${aws_subnet.default.id}"

  tags {
    environment = "non-production"
    Name        = "${var.hostname}"
  }

# output IP and DNS to local file
  provisioner "local-exec" {
    command = "echo ${aws_instance.ansible-node.public_dns} > hosts"
  }
}

output "public_ip" {
  value = "${aws_instance.ansible-node.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.ansible-node.public_dns}"
}
