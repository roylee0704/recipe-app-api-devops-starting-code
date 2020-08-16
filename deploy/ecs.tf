
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
