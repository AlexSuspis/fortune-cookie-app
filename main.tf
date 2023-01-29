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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC73EuM9lAi1LBeAWiwZjCem3BjCIf04rRp3RPYixLCl8rDU2QAMjuJ99pYUcoKLqHvaLrxCLm4STo68BzowuXsakDaY3qTEmQcHPZ68Yxfg/pS4gmxlHIoACKxcllWdgS32/61hRTZ1EdOVL0a9WjFntIAhmZtieHkoKbSs3Ofna7j/uBdRz+nKvqfuMbpWq6SS2f8U3RTOV4QqOCm4P/e+jdDklIQRv3g9EtTu69jTZEDUfPnGbaj81nA6TNTuWG21K7Nh0gE0V0cPk1xz5RUVuVtkxVgpdenIZYaAkRJ0p41ucM/OZPFRTx44fma/CJ8QUkgpSNChYVxPTeKM857 alex@Alexandres-Air.home"
}
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  #   user_data = <<-EOF
  #               #!/bin/bash
  #               apt-get update
  #               apt-get install -y apache2
  #               sed -i -e 's/80/8080/' /etc/apache2/ports.conf
  #               echo "Hello World" > /var/www/html/index.html
  #               systemctl restart apache2
  #               EOF
  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"

    connection {
      type = "ssh"
      user = "ubuntu"
      #   private_key = file("/Users/alex/iCloud/coding/fortune-cookie-app/ssh-private-key.pem")
      private_key = aws_key_pair.deployer.public_key
      host        = self.public_ip
    }
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
