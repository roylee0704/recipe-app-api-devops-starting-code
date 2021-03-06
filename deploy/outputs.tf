# when you run terraform, you can set its output of 
# certain variables or attributes of our resources 
# to the console


# i.e: output db address, when we deploy - we can see it

output "db_host" {

  # internal network address of db
  value = aws_db_instance.main.address

}

output "bastion_host" {
  value = aws_instance.bastion.public_dns
}


# creates new output value for load balancer dns name
# once its been created by Terraform
output "api_endpoint" {
  value = aws_lb.api.dns_name
}