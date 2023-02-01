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

variable "ssh-public-key-path" {
  type = string
}
variable "ssh-private-key-path" {
  type = string
}
data "aws_availability_zones" "available" {}
resource "random_pet" "sg" {}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh-public-key-path)
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

# resource "aws_instance" "web" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.deployer.key_name
#   vpc_security_group_ids = [aws_security_group.instance.id]
# }




resource "aws_launch_template" "app" {
  name_prefix            = "app"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  user_data              = filebase64("./ec2-setup.sh")
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  # provisioner "remote-exec" {
  #   inline = [
  #     "touch hello.txt",
  #     "echo helloworld remote provisioner >> hello.txt",
  #   ]
  # }
  # connection {
  #   type        = "ssh"
  #   host        = aws_instance.web.public_ip
  #   user        = "ubuntu"
  #   private_key = file(var.ssh-private-key-path)
  #   timeout     = "4m"
  # }
}
resource "aws_security_group" "instance" {
  name = "web-instance"
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


## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity   = 2
  min_size           = 1
  max_size           = 5
  load_balancers     = ["${aws_elb.elb.id}"]
  #   target_group_arns  = ["${resource.aws_elb.target_group_arn}"]
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
### Creating ELB
resource "aws_elb" "elb" {
  name               = "elb"
  security_groups    = ["${aws_security_group.elb.id}", "${aws_security_group.ssh.id}"]
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
## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "elb_security_group"
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
}
## Security Group for SSH connection
resource "aws_security_group" "ssh" {
  name = ""
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 20
    to_port     = 20
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




output "elb_public_dns" {
  value = "${aws_elb.elb.dns_name}:80"
}
output "elb_instances" {
  value = aws_elb.elb.instances
}
output "ssh-public-key" {
  value = aws_key_pair.deployer.public_key
}
output "ssh-private-key" {
  value = file(var.ssh-private-key-path)
}
