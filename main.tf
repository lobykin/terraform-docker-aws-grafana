terraform {
  required_version = ">=0.13.4"
  backend "s3" {
    bucket         = "nginx-dynamo-bucket-88"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nginx-locks-2"
    encrypt        = true
  }
}
