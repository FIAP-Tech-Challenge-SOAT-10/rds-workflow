provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.aws_role_to_assume
    session_name = "github-actions-terraform"
  }
}
