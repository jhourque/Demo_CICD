output "ecr_app_id" {
  value = "${aws_ecr_repository.website.registry_id}"
}

output "ecr_app_url" {
  value = "${aws_ecr_repository.website.repository_url}"
}

output "keypair" {
  value = "${aws_key_pair.app-key.key_name}"
}
