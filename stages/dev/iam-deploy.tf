/**
* Povio Terraform PS1
* Version 2.0
*/

# ECS Access
resource "aws_iam_policy" "deploy_ecs_access" {
  name = "${var.stage_slug}-gold-price-tracker-ecs-access"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      // Resource-level permission control for ECS Task Definitions is currently not available.
      // https://github.com/aws/containers-roadmap/issues/929
      {
        Effect : "Allow",
        Action : [
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeServices"
        ],
        Resource : [
          "*"
        ]
      },
      {
        Effect : "Allow",
        Action : [
          "ecs:UpdateService"
        ],
        Resource : aws_ecs_service.this.id
      },
      {
        Action : [
          "iam:PassRole"
        ],
        Effect : "Allow",
        Resource : [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ],
        Condition : {
          "StringLike" : {
            "iam:PassedToService" : [
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Stage = var.stage_slug
  }
}
