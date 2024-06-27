resource "aws_alb" "this" {
  name    = "${var.stage_slug}-loadbalancer"
  subnets = aws_subnet.public.*.id
  security_groups = [
    aws_security_group.public_security_group.id
  ]
  internal = false
  #load_balancer_type = "application"
  #ip_address_type    = "ipv4"
}

# create Application Load Balancer Listener with default static response
resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.id
  port              = 80
  protocol          = "HTTP"
  # certificate_arn   = var.listener_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "400"
      message_body = "Nothing here!"
    }
  }

  tags = {
    Stage = var.stage_slug
  }
}

# ALB Target Group
resource "aws_alb_target_group" "this" {
  name     = "${var.stage_slug}-gold-price-tracker-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  # todo, move to instance
  target_type = "ip"
  health_check {
    port = 80
    path = "/"
  }
}


# add forwarding rule to target group to existing listener
resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_alb_listener.this.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

