# create Security Group for load balancer (ALB).
resource "aws_security_group" "public_security_group" {
  name        = "${var.stage_slug}-gold-price-tracker-alb-public-sh"
  description = "Controls incoming access to Load Balancer"
  vpc_id      = aws_vpc.this.id

  # allow all inbound traffic for a given port, TCP protocol and any IP
  # todo, limit access to cloudfront
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # allow all outbound traffic for any port, protocol and IP
  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "db_security_group" {
  name   = "${var.stage_slug}-gold-price-tracker-database-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Stage = var.stage_slug
  }
}

resource "aws_security_group" "redis_security_group" {
  name   = "${var.stage_slug}-gold-price-tracker-elasticache-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = "tcp"
    from_port = 6379
    to_port   = 6379
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Stage = var.stage_slug
  }
}

# Security groups for access to this service
resource "aws_security_group" "ecs_security_group" {
  name        = "${var.stage_slug}-gold-price-tracker-api"
  vpc_id      = aws_vpc.this.id
  description = "[${var.stage_slug}] ECS Service gold-price-tracker api"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [
      aws_security_group.public_security_group.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
