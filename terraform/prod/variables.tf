### Shared variables
variable project_name {
  default = "demo-devops-prod"
}

terraform {
  backend "s3" {
    bucket = "demodevops-tfstate"
    key    = "prod.tfstate"
    region = "eu-west-1"
  }
}

