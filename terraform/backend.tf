terraform {
  backend "s3" {
    bucket = "s3-rb.tf-r0410"
    key    = "amazonaiproject/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock"
  }
}