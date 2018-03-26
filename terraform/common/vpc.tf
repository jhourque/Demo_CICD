### Variables
variable region {
  default = "eu-west-1"
}

variable "azs" {
  default = {
    "eu-west-1" = ["eu-west-1a", "eu-west-1b"]
    "eu-west-2" = ["eu-west-2a", "eu-west-2b"]
    "eu-central-1" = ["eu-central-1a", "eu-central-1b"]
  }
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

### Provider
provider "aws" {
  region = "${var.region}"
}

### Resources
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  count                   = "${length(var.azs[var.region])}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, count.index)}"
  availability_zone       = "${element(var.azs[var.region], count.index)}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.project_name}_public_${count.index}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.main.id}"
  count                   = "${length(var.azs[var.region])}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, count.index+127)}"
  availability_zone       = "${element(var.azs[var.region], count.index)}"
  map_public_ip_on_launch = "false"

  tags {
    Name = "${var.project_name}_private_${count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.project_name}_public"
  }
}

resource "aws_route_table_association" "rtap" {
  count          = "${length(var.azs[var.region])}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}
