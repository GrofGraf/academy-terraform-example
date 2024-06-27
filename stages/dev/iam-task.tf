#
# Configure Policies for ECS Task Role
#

data "aws_iam_policy_document" "ecs_task_role_principal" {
  statement {
    effect = "Allow"
    actions = [
    "sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
      "ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.stage_slug}-gold-price-tracker-api-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_principal.json
}
