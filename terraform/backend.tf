terraform {
  backend "s3" {
    bucket         = "umami-terraform-state-2338"
    key            = "umami/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
