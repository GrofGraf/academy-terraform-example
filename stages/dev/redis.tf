resource "random_password" "redis_password" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "redis_password" {
  name  = "/${var.stage_slug}/redis/password"
  type  = "SecureString"
  value = random_password.redis_password.result

  tags = {
    Stage = var.stage_slug
  }
}


# create ElastiCache Subnet Group - placement in private/restricted subnet
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.stage_slug}-gold-price-tracker-elasticache"
  subnet_ids = aws_subnet.public.*.id

  tags = {
    Stage = var.stage_slug
  }
}

resource "aws_elasticache_replication_group" "this" {
  num_cache_clusters   = 1
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  replication_group_id = "${var.stage_slug}-gold-price-tracker-elasticache"
  description          = "${var.stage_slug} redis"
  engine               = "redis"
  port                 = 6379
  engine_version       = "6.x"
  node_type            = "cache.t2.micro"
  security_group_ids = [
    aws_security_group.redis_security_group.id
  ]
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_password.result

  tags = {
    Stage = var.stage_slug
  }
}
