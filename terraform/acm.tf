data "aws_acm_certificate" "main" {
  domain = "mahintechlab.com"
  statuses = ["ISSUED"]
  most_recent = true
}