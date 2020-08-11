
resource "aws_vpc" "main" {

  # cidr block is a way to shortern the netmasks
  # in a way that it can written just in one line.

  # 10.1 gives you the prefix of our ip addresses.
  # /16 gives you about 65534 of hosts/addresses.
  #                subnet/netmasks
  cidr_block = "10.1.0.0/16"


  # have nice hostname to our internal network
  # easier to use when we manually perform
  # the adminitration tasks.
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-vpc")
  )
}


resource "aws_internet_gateway" "main" {

  # set the vpc
  # M-1 link to vpc
  vpc_id = aws_vpc.main.id


  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}

# Public subnets are used to give resources access to the internet publicly.
# resources: https://www.aelius.com/njh/subnet_sheet.html

#####################################################
# Public Subnets - Inbound/Outbound Internet Acesss #
#####################################################

# subnet is like a namespace to isolate resources
# if you assiciate a subnet to route-table that has 
# access to internet gateway, then it automatically becomes
# "public".
resource "aws_subnet" "public_a" {

  # /24 gives us 254 hosts.
  # 10.1.1: the prefix to all ip addresses under this subnet A.
  # i.e: 10.1.1.1 - first resource, 10.1.1.2 - second resource, etc.
  cidr_block = "10.1.1.0/24"

  # anything we add to the subnet will get a public IP address.
  # add bastion instance, ec2 instance, etc will be given a public
  # IP address that is accessible from the internet.
  map_public_ip_on_launch = true

  # set the vpc
  # M-1 link to vpc
  vpc_id = aws_vpc.main.id

  # a way of dividing regions up in to separate zones so 
  # that if one of the zones goes down, the other zone 
  # can take over and handle all of the traffic.
  #
  # good practise: create subnets in more than 1 availability zone
  # also required: for creating things like a load balancer.
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}


# a way of adding route to a subnet
# btw: "public_a" is just a local var name to be used within
# terraform context.
resource "aws_route_table" "public_a" {
  # M-1 link to vpc
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}

# it creates an association/link between our route table
# and subnet.
# 
# this resouce doesn't support tags
resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id

  # why not put subnet_id in route_table?
  # b'cos maybe other subnets also want to share it!
  #
  # M-M relationships between route table and subnet
  route_table_id = aws_route_table.public_a.id
}


# adding new row `route: public_internet_access_a` 
# to `table: public_a`.
#
# this resouce doesn't support tags
resource "aws_route" "public_internet_access_a" {
  # M-1 link to route-table
  route_table_id = aws_route_table.public_a.id

  # 0.0.0.0/0 means all IP addresses
  # aka. the public internet
  destination_cidr_block = "0.0.0.0/0"

  # M-1 link to gateway
  gateway_id = aws_internet_gateway.main.id
}



# elastic ip 
# this is the way of creating an IP address
# in our aws VPC 
resource "aws_eip" "public_a" {
  vpc = true

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}


# network address translation
# allow private subnet to have outbound access, but not inbound access.
resource "aws_nat_gateway" "public_a" {

  # an allocation of the EIP
  allocation_id = aws_eip.public_a.id

  # creating the nat in the public subnet
  # M-1 link
  subnet_id = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}



resource "aws_subnet" "public_b" {
  availability_zone       = "${data.aws_region.current.name}b"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public_b.id
  subnet_id      = aws_subnet.public_b.id
}

resource "aws_eip" "public_b" {
  vpc = true
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}