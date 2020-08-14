# when you run terraform, you can set its output of 
# certain variables or attributes of our resources 
# to the console


# i.e: output db address, when we deploy - we can see it

output "db_host" {

  # internal network address of db
  value = aws_db_instance.main.address

}