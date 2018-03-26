resource "aws_dynamodb_table" "ddb" {
    name            =  "ddb_table_demo"
    read_capacity   =  "100"
    write_capacity  =  "100"
    hash_key        =  "lastname"
    range_key       =  "firstname"
    attribute {
        name = "lastname"
        type = "S"
    }
    attribute {
        name = "firstname"
        type = "S"
    }
}

resource "aws_iam_role_policy" "ddb_admin" {
    name = "ddb_admin_role_policy_demo"
    role = "${aws_iam_role.web.id}"
    policy = <<EOF
{
    "Statement": [
        {
            "Effect":"Allow",
            "Action":[
                "dynamodb:*"
            ],
            "Resource": "${aws_dynamodb_table.ddb.arn}"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}
