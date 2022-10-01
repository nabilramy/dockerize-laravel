
resource "aws_ecs_task_definition" "this" {
  family                   = local.application_name
  requires_compatibilities = [local.launch_type]

  cpu                      = "256"
  network_mode             = "awsvpc"
  memory                   = "512"
  # container_definitions = 
}
