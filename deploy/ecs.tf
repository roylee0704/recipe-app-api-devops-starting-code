# 1x cluster per environment
resource "aws_ecs_cluster" "main" {

  # due to 1x, that's why we name it as cluster
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

################################################################################
# assigning the permissions in order to start a task
#
# create new aws policy in our AWS account, named "task-exec-role-policy"
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  description = "Allow retriving of images and adding to logs"

  # set policy to root path (a way of organising policies in AWS)
  path   = "/"
  policy = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}
#
#############################################################################



############################################################################
# assigning the permissions to our task that it needs at run time.
#
# another role to be used by the app running in the containers.
resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-api-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}
#
#
# note: for now, there is no policy attached to it yet, just a placeholder role 
# to be assumed. we will add in policy along the way
#############################################################################

##############################################################################
# by default, 
# - container logs are output to the console.
# - a random log group will created by our cloud watch.
# 
# log group: to group all of the logs of a particular task in one place.
#
# then, we can assign "task" to this log group, so that the log output for 
# our console (application log) go to this location below. 
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"
  tags = local.common_tags
}

# from *.tfvars or TF_VARS_ -> variables.tf -> this
data "template_file" "api_container_definitions" {
  template = file("./templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image   = var.ecr_image_api
    proxy_image = var.ecr_image_proxy

    db_host           = aws_db_instance.main.address
    db_name           = aws_db_instance.main.name
    db_user           = aws_db_instance.main.username // var.db_username
    db_pass           = aws_db_instance.main.password // var.db_password
    django_secret_key = var.django_secret_key

    log_group_name   = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region = data.aws_region.current.name

    allowed_hosts = "*"
  }
}


# this is the main entry-point to run ECS cluster
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.prefix}-api"
  container_definitions    = data.template_file.api_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn


  volume {
    name = "static"
  }

  tags = local.common_tags
}
