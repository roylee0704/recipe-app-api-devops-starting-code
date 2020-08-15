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




# role have access to ecr repo: pull down docker images
resource "aws_iam_role" "bastion" {
  name = "${local.prefix}-bastion"

  # can be assumed by which principals? i.e: ec2, lambda, etc...
  assume_role_policy = file("./templates/bastion/instance-profile-policy.json")
  tags               = local.common_tags

}

resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role = aws_iam_role.bastion.name

  # predefined by aws 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# instance profile is a container to hold a role name.
# Any role name that is placed under an instance profile will be used 
# to run assume-role command internally by ec2.
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}

# create resource
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  # ./ takes us to the root of a directory, "deploy"
  # you may add script to this attribute
  user_data = file("./templates/bastion/user-data.sh")

  
  # assign an instance profile to ec2
  iam_instance_profile = aws_iam_instance_profile.bastion.name

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

