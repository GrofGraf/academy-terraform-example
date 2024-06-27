
terraform {
  backend "s3" {
    bucket         = "dev-gold-price-tracker-terraform-state"
    dynamodb_table = "dev-gold-price-tracker-terraform-lock"
    key            = "my-terraform-project"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
