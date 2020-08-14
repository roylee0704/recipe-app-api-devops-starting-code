
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