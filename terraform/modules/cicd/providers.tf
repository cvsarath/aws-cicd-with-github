terraform {
  required_providers {
    aws = {
      version = "~> 4.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}