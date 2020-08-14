
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

variable "db_username" {
  description = "Username for the RDS postgres instance"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
}