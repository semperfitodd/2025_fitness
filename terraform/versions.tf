provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "todd_2025_fitness"
      Owner       = "Todd"
      Provisioner = "Terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
  required_version = "1.11.2"
}