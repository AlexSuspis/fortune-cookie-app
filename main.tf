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

data "aws_availability_zones" "available" {}
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

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #   key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y apache2
                sed -i -e 's/80/8080/' /etc/apache2/ports.conf
                echo "<h1>Fortune cookie app coming soon!</h1>" > /var/www/html/index.html
                systemctl restart apache2
                EOF
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

resource "aws_launch_template" "app" {
  name_prefix   = "app"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #   security_groups = aws_security_group.web-sg.id
  user_data = <<EOF
                #!/bin/bash
                apt-get update
                apt-get install -y apache2
                sed -i -e 's/80/8080/' /etc/apache2/ports.conf
                echo "<h1>Fortune cookie app coming soon!</h1>" > /var/www/html/index.html
                systemctl restart apache2
                EOF
}


## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity   = 1
  min_size           = 1
  max_size           = 5
  load_balancers     = ["aws_elb.example.name"]
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
} ## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
} ### Creating ELB
resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  security_groups    = ["${aws_security_group.elb.id}"]
  availability_zones = data.aws_availability_zones.available.names
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8080"
    instance_protocol = "http"
  }
}




output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
