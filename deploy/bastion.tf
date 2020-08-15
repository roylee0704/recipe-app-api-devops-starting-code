# bastion is a server that allows administrators to 
# connect to our resources in the private subnet.

# query resource
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}


# create resource
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  # ./ takes us to the root of a directory, "deploy"
  # you may add script to this attribute
  user_data = file("./templates/bastion/user-data.sh")


  # this is like metadata in kubernetes manifest
  # tags = {
  #   Name = "${local.prefix}-bastion" # raad-dev-bastion
  # }
  #
  # for overriding purposes
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-bastion")
  )
}

