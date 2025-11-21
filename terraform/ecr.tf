resource "aws_ecr_repository" "umami" {
  name                 = "umami"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "umami-repo"
  }

}


output "ecr_repo_url" {
  value = aws_ecr_repository.umami.repository_url
}
