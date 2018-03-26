### Variables
variable branch {
  default = "master"
}

variable app_version {
}

variable front_instance_number {
  default = "2"
}

variable front_ami {
  default = "ami-f90a4880" # Ubuntu 16.04
}

variable front_instance_type {
  default = "t2.micro"
}

variable front_elb_port {
  default = "80"
}

variable front_elb_protocol {
  default = "http"
}

### Datasources
data "terraform_remote_state" "static" {
  backend = "s3"
  config {
    bucket = "demodevops-tfstate"
    key    = "static.tfstate"
    region = "eu-west-1"
  }
}
data "template_file" "userdata" {
  template = "${file("files/userdata.sh")}"

  vars {
    REPO = "${data.terraform_remote_state.static.ecr_app_url}:${var.app_version}"
    REGION = "${var.region}"
	TABLE = "${aws_dynamodb_table.ddb.id}"
  }
}

### Resources
resource "aws_iam_role" "web" {
  name = "ECR_access-${var.branch}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "web_ecr" {
  name        = "ECR_access-${var.branch}"
  description = "policy for ECR access from EC2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "web_log" {
  name        = "web_log-${var.branch}"
  description = "log policy for EC2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "web_ecr_attach" {
  role       = "${aws_iam_role.web.name}"
  policy_arn = "${aws_iam_policy.web_ecr.arn}"
}

resource "aws_iam_role_policy_attachment" "web_log_attach" {
  role       = "${aws_iam_role.web.name}"
  policy_arn = "${aws_iam_policy.web_log.arn}"
}

resource "aws_iam_instance_profile" "web_instance_profile" {
    name = "ECR_instance_profile-${var.branch}"
    role = "${aws_iam_role.web.name}"
}

resource "aws_instance" "front" {
  count                  = "${var.front_instance_number}"
  ami                    = "${var.front_ami}"
  instance_type          = "${var.front_instance_type}"
  key_name               = "${data.terraform_remote_state.static.keypair}"
  subnet_id              = "${element(aws_subnet.public.*.id, count.index % length(aws_subnet.public.*.id))}"
  vpc_security_group_ids = ["${aws_security_group.front.id}"]
  user_data              = "${data.template_file.userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.web_instance_profile.id}"

  tags {
    Name = "front${count.index}"
  }
}

resource "aws_elb" "front" {
  # TO DO
  # see https://www.terraform.io/docs/providers/aws/r/elb.html
  name            = "${var.project_name}-elb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:8080/"
    interval            = 5
  }
  instances = ["${aws_instance.front.*.id}"]
}

### Outputs
output "elb_endpoint" {
  # TO DO
  # see https://www.terraform.io/intro/getting-started/outputs.html
  value = "${aws_elb.front.dns_name}"
}

output "instance_ip" {
  value = "${aws_instance.front.*.public_ip}"
}
