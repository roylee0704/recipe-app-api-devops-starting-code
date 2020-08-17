
# useful if you have a lot of resources in aws
variable "prefix" {
  default = "raad"
}


variable "project" {
  default = "roy-recipe-app-api-devops"
}

variable "contact" {
  default = "roy@gobike.com"
}


# db username and password, allow these values 
# to pass in from github-ci(actions) variable configurations
#
# couple ways to set value:
# 1. variables.tf
# 2. manual type on terraform plan
# 3. TF_VARs file (sample.tfvars + terraform.tfvars)
# 4. env variables
# 
# common practise: sample TF_VARS file
#
# in this project, will set it in TF_VARS file, on ci tool.
variable "db_username" {
  description = "Username for the RDS postgres instance"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
}

# refer to key name defined in AWS > EC2 > Key Pairs (pub keys)
variable "bastion_key_name" {
  # this is a default value
  default = "roy-recipe-app-api-devops-bastion"
}

variable "ecr_image_api" {
  description = "ECR image for API"
  default = "439299810195.dkr.ecr.ap-southeast-1.amazonaws.com/roy-recipe-app-api-devops"
}

variable "ecr_image_proxy" {
  description = "ECR image proxy"
  # default = ""
}

# without default, means need to pass in from 
# - locally -> terraform.tfvars
# - ci -> TF_VARS_
variable "django_secret_key" {
  description = "Secret key for Django app"
}