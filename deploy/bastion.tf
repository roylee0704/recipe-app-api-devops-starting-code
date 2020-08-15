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


  key_name = var.bastion_key_name

  # assign to subnet.
  # why public? want it to be accessible for the public 
  # why not public b? because bastion is not a very critical services
  # if want to have available on 2 availability zones, 2 bastions one a, one b, however it's overkill.
  # however, if a is down, then change the code to b and redeploy.
  subnet_id = aws_subnet.public_a.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

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


# controls the network access from/to bastion instance
# security group is like a firewall.
resource "aws_security_group" "bastion" {
  description = "Control bastion inbound and outbound access"
  name        = "${local.prefix}-bastion"
  vpc_id      = aws_vpc.main.id
  tags        = local.common_tags

  # public users can reach bastion instance on port 22 (SSH)
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    # allow acess from any ip address 
    # usually refers to your hosted ip address. 
    # if your company supports static ip address, then you can actually set it here.
    #
    # if you have a dynamic ip address - it changes frequently 
    # hence you can't hardcode here.
    cidr_blocks = ["0.0.0.0/0"]
  }


  # not recommended: simply allow entire outbound access from server, because once hacker get into the box,
  # he/she can basically connect to ANY SERVERs. Limit them as much as possible.
  #
  # within bastion instance (after ssh-ed), 
  # he can access to port 443 (over HTTPS): 
  # 
  # - accesing package repository in order to install upgrades
  # = to pull images from ECR 
  egress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    # from any ip address
    cidr_blocks = ["0.0.0.0/0"]
  }

  # he can goto port 80 (over HTtp): update/upgrade packages 
  # 
  # - accesing package repository in order to install upgrades
  # = to pull images from ECR 
  egress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    # from any ip address
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Can goto port 5432: postgres resides in private subnets.
  # 
  # if you also want to able to access to other application via 
  # other port, just declare additional egress block
  egress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432

    # copy/paste IP address range of private subnets 
    cidr_blocks = [
      aws_subnet.private_a.cidr_block, # 10.1.10.0/24
      aws_subnet.private_b.cidr_block, # 10.1.11.0/24
    ]
  }
}