### Shared variables
variable project_name {
  default = "demo-devops-dev"
}

terraform {
  backend "s3" {
    bucket = "demodevops-tfstate"
    key    = "dev.tfstate"
    region = "eu-west-1"
  }
}

