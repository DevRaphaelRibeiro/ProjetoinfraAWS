# Configure the AWS Provider

/*provider "aws" {
    region = var.region
  
}
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.59.0"

    }
  }
}

provider "aws" {
  region = var.region
}