locals {
  application_name = "laravel_app"
  launch_type      = "FARGATE"
}


resource "aws_ecs_cluster" "this" {
  name = "${local.application_name}-cluster"
}


resource "aws_ecs_service" "this" {
  name            = "service"
  cluster         = aws_ecs_cluster.this.arn
  task_definition = "${aws_ecs_task_definition.this.family}:${aws_ecs_task_definition.this.revision}"

  desired_count   = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 200
  launch_type = "FARGATE"

  network_configuration {
    assign_public_ip  = true
    security_groups  = data.aws_security_groups.this.ids
    subnets          = data.aws_subnet_ids.this.ids
    
  }
}

# RDS MySQL (single zone)
resource "aws_db_subnet_group" "this" {
  name       = "${local.application_name}-db-subnet-group"
  subnet_ids = data.aws_subnet_ids.this.ids
}

resource "aws_db_instance" "this" {
  identifier              = "${local.application_name}-db"
  engine                  = "mysql"
  engine_version          = "8.0.0"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  name                    = "laravel"
  username                = "root"
  password                = ""
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = data.aws_security_groups.this.ids
  skip_final_snapshot     = true
  storage_type            = "gp2"
  deletion_protection     = false
  multi_az                = false
  backup_retention_period = 0
  apply_immediately       = true
}

resource "aws_security_group_rule" "rds" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [""]
  security_group_id = aws_db_instance.this.vpc_security_group_ids[0]
}





