
#
# Configure Policies for ECS Task Executor
#

data "aws_iam_policy_document" "ecs_execution_principal" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid    = "ServiceDefaults"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.stage_slug}-gold-price-tracker-api-exec-basic"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_principal.json
}

resource "aws_iam_role_policy" "ecs_execution" {
  name   = "${var.stage_slug}-gold-price-tracker-api-exec-basic"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_execution.json
}
