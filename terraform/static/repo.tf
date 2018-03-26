variable "region" {
  type = "string"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_ecr_repository" "website" {
  name = "demo/website"
}
