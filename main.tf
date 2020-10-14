terraform {
  required_version = ">=0.13.4"
  backend "s3" {
    bucket         = "nginx-dynamo-bucket-888"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "grafana-locks"
    encrypt        = true
  }
}

# Call the seed_module to build grafana App
module "docker" {
  source             = "./terraform/docker"
  
}