terraform {
  backend "s3" {
    bucket         = "roy-recipe-app-devops-tfstate"
    key            = "roy-recipe-app.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "roy-recipe-app-devops-tf-state-lock"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  version = "~>2.54.0"
}

# local variables 
locals {
  prefix = "${var.prefix}-${terraform.workspace}" # raad-dev

  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}


# retrieve current region that we are working on
# empty block b'cos we do need to assign any attributes 
# to our aws_region
#
# no need to hardcode
data "aws_region" current {}