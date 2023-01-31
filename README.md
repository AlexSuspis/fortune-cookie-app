# fortune-cookie-app

A simple web app integrating a CI/CD pipeline in Github Actions, automated deployment to AWS EC2, and Terraforming for automated cloud infrastructure setup.

Terraform file main.tf is triggered each time a Github push request is made: see .github/workflows/deploy.yaml for more info.

Can also run 'terraform plan' or 'terraform apply' on the CLI to trigger Terraform process. 
