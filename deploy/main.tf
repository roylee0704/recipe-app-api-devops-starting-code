terraform {
    backend "s3" {
        bucket = "roy-recipe-app-devops-tfstate"
        key = "roy-recipe-app.tfstate"
        region = "ap-southeast-1"
        encrypt = true
        dynamodb_table = "roy-recipe-app-devops-tf-state-lock"
    }
}

provider "aws" {
    region = "ap-southeast-1"
    version = "~>2.54.0"
}