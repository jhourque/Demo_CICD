terraform {
  backend "s3" {
    bucket = "demodevops-tfstate"
    key    = "static.tfstate"
    region = "eu-west-1"
  }
}

