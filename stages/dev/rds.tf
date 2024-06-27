resource "random_password" "db_password" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.stage_slug}/db_password"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_db_subnet_group" "db_subnet" {
  name_prefix = "${var.stage_slug}-gold-price-tracker-rds"
  subnet_ids  = aws_subnet.public.*.id

  tags = {
    Stage = var.stage_slug
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${var.stage_slug}-gold-price-tracker-db"
  db_name           = "goldpricetracker"
  instance_class    = "db.t3.micro"
  engine            = "postgres"
  allocated_storage = 10
  username          = "root"
  password          = random_password.db_password.result
  vpc_security_group_ids = [
    aws_security_group.db_security_group.id
  ]
  db_subnet_group_name      = aws_db_subnet_group.db_subnet.name
  publicly_accessible       = true
  final_snapshot_identifier = "${var.stage_slug}-gold-price-tracker-db-final-snapshot"

}
