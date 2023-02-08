provider "aws" {
  region = "us-west-2"
}

resource "aws_elastic_beanstalk_application" "fortune_cookie_app" {
  name        = "fortune-cookie-app"
  description = "My first app deployed on Elastic Beanstalk"
}

resource "aws_elastic_beanstalk_environment" "fortune_cookie_app_env" {
  name                = "fortune-cookie-app-env"
  application         = aws_elastic_beanstalk_application.fortune_cookie_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.4 running Node.js 16"
}
