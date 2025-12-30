output "public_ip"{
        value = aws_instance.my_ec2.public_ip
}

output "backend_ecr_uri" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_uri" {
  value = aws_ecr_repository.frontend.repository_url
}