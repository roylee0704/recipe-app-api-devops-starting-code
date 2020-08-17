# contains all the infrastrure for our database
# most of them are network related.


# database has a special resource call db-subnet-group
# that allows you to add multiple subnets to your
# database.
resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-name"

  # it can be stay in the private network, cos 
  # it doesn't need to be accessible from the outside world.
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  tags = merge(
    local.common_tags,

    # glitch in aws - if we dont put here, it wont 
    # show on the console.
    map("Name", "${local.prefix}-main")
  )
}


# allows you to control the inbound and outbound access
# allowed to that resource.
resource "aws_security_group" "rds" {
  description = "Allow access to the RDS database instance"


  # rds-inbound-access. we know this is the security group that manage 
  # inbound rds access.
  name = "${local.prefix}-rds-inbound-access"

  vpc_id = aws_vpc.main.id

  # controls what the rules are for the 
  # inbound access. 
  # opposite: egress - outbound access
  #
  # we only need to allow inbound access 5432
  # for our database. So our application services,  
  # entire private network can access to it.
  ingress {
    protocol = "tcp"

    # default port for postgres
    from_port = 5432
    to_port   = 5432

    # by default, cidr_blocks = "0.0.0.0/0" 
    # it allows anyone who knows the port to access
    #
    # but now, I only want to allow access from bastion instance.
    # one way is to specify the security group
    #
    # why security group? 
    # although you are expecting inbound access from public subnet, but you def do not want to 
    #    specify cidr_blocks from public subnet (cos anyone can enter to public subnet).
    #
    # why not bastion instance ip address?
    # bastion instance ip address changes as it spawned, unless you know the ip address range (which is impossible) 
    # or maybe aws_instance.bastion.ip_address?
    security_groups = [
      aws_security_group.bastion.id
    ]
  }

  tags = local.common_tags
}


# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
/** Assignment
Modify the same Terraform to create a new database instance with the following specifications:
- Uses the MySQL engine (version 5.7)
- Runs as a db.t2.micro class
- Has the default username: user
- Has the default password: password
- Has 5GB of allocated storage
- Has the identifier assignment-db
- Set skip final snapshot to true
*/
resource "aws_db_instance" "main" {

  # used within console
  identifier = "${local.prefix}-db"

  name     = "recipe" # to define database name 
  username = var.db_username
  password = var.db_password

  allocated_storage = 20            # faily low cost options
  storage_type      = "gp2"         # ssd general purpose 2  (low entry)
  instance_class    = "db.t2.micro" # server type for our db

  engine         = "postgres"
  engine_version = "11.4"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id, aws_security_group.ecs_service.id]

  # disclaimer: settings below are not for production
  backup_retention_period = 0     # num of days you want to maintain backups for
  multi_az                = false # if db should run on multi az, note: subnet-group we have az support
  skip_final_snapshot     = true  # before destroy db, it will snapshot. note: terraform have bug due to it uses db id to create snapshot.

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}