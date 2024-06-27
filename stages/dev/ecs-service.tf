#
# Create ECS Task Definition, Service and Container Definition.
#
locals {
  log_group_name = "/ecs/${var.stage_slug}/gold-price-tracker-api"

  container_definitions = [
    {
      cpu         = 256
      image       = "nginx:latest",
      memory      = 512,
      name        = "${var.stage_slug}-gold-price-tracker-api"
      networkMode = "awsvpc",
      essential   = true,
      mountPoints = []
      volumesFrom = []
      portMappings = [
        {
          hostPort      = 80,
          protocol      = "tcp",
          containerPort = 80
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = local.log_group_name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "${var.stage_slug}-gold-price-tracker-api"
        }
      },
    }
  ]
}

# create Cloud Watch log group
resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = 30
  tags = {
    Stage = var.stage_slug
  }
}


# Create ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family       = "${var.stage_slug}-gold-price-tracker-api"
  cpu          = 256
  memory       = 512
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html
  container_definitions = jsonencode(local.container_definitions)

  tags = {
    Stage = var.stage_slug
  }
}

# Create ECS Service
resource "aws_ecs_service" "this" {
  name          = "${var.stage_slug}-gold-price-tracker-api"
  cluster       = aws_ecs_cluster.this.id
  desired_count = 1

  task_definition = aws_ecs_task_definition.this.arn

  platform_version = "LATEST"

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    security_groups = [
      aws_security_group.ecs_security_group.id
    ]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this.id
    container_name   = "${var.stage_slug}-gold-price-tracker-api"
    container_port   = 80
  }

}
