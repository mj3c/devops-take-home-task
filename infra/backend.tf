terraform {
  backend "s3" {
    bucket       = "devops-take-home-task"
    region       = "eu-central-1"
    key          = "" # Will be supplied from the command-line
    use_lockfile = true
    encrypt      = true
  }
}