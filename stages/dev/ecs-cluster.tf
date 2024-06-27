resource "aws_ecs_cluster" "this" {
  name = "${var.stage_slug}-gold-price-tracker-api"

  tags = {
    Stage = var.stage_slug
  }
}
