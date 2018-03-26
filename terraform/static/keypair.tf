variable project_name {
}

variable keyp {
}

resource "aws_key_pair" "app-key" {
  key_name   = "${var.project_name}-key"
  public_key = "${file(var.keyp)}"
}

