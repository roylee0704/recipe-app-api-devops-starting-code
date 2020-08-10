
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
  # this is like metadata in kubernetes manifest
  # tags = {
  #   Name = "${local.prefix}-bastion" # raad-dev-bastion
  # }

  # for overriding purposes
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-bastion")
  )
}

