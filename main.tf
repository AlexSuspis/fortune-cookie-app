terraform {
  cloud {
    organization = "alexsuspis"

    workspaces {
      name = "fortune-cookie-app"
    }
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
  }
}

provider "aws" {
  region                  = "eu-west-2"
  profile                 = "default"
  shared_credentials_file = "$HOME/.aws/credentials"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_eb_profile" {
  name = "fortune-cookie-app-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "fortune-cookie-app-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}
resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name  = "ec2_attachment"
  roles = [aws_iam_role.ec2_role.name]

  policy_arn = aws_iam_policy.ec2_policy.arn

}
data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_elastic_beanstalk_application" "fortune_cookie_app" {
  name        = "fortune-cookie-app"
  description = "My first app deployed on Elastic Beanstalk"
}

resource "aws_elastic_beanstalk_environment" "fortune_cookie_app_env" {
  name                = "fortune-cookie-app-env"
  application         = aws_elastic_beanstalk_application.fortune_cookie_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.4 running Node.js 16"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_eb_profile.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 2
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
}
