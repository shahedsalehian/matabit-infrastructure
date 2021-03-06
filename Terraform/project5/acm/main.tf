terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "acm/state.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_acm_certificate" "matabit-cert" {
  domain_name       = "matabit.org"
  validation_method = "EMAIL"

  subject_alternative_names = ["*.matabit.org"]
}
