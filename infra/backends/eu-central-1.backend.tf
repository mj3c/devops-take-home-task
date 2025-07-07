terraform {
  backend "s3" {
    bucket         = "incode-take-home-task"
    region         = "eu-central-1"
    key            = "eu-central-1/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}