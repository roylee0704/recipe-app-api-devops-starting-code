resource "aws_vpc" "main" {
  # a block that indicate what ip-addresses will be 
  # appearing in our network

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

  # assign to vpc
  vpc_id = aws_vpc.main.id


  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}