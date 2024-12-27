terraform {
  backend "s3" {
    bucket = "bernson.terraform"
    key    = "todd_2025_fitness/terraform.tfstate"
    region = "us-east-2"
  }
}
