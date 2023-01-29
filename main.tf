terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "alexsuspis"

    workspaces {
      name = "fortune-cookie-app"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "random_pet" "sg" {}

# Key generation
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = "key_name"
  public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y apache2
                sed -i -e 's/80/8080/' /etc/apache2/ports.conf
                echo "Hello World" > /var/www/html/index.html
                systemctl restart apache2
                EOF

  connection {
    type = "ssh"
    user = "ubuntu"
    # private_key = file("${path.module}/id_rsa")
    private_key = tls_private_key.example.private_key_pem
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "/Users/alex/iCloud/coding/fortune-cookie-app/index.html"
    destination = "/var/www/html/index.html"
  }
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
output "instance_id" {
  value = aws_instance.web.instance_id
}
# output "ssh-key" {
#   value = tls_private_key.example.private_key_pem
# }
