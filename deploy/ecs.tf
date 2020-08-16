
# 1x cluster per environment
resource "aws_ecs_cluster" "main" {

  # due to 1x, that's why we name it as cluster
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}