# ecs task definition -> will use 1 template.
#  ecs cluser
# ecs service -> will map this to load balancer 


# ecs cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.app_name}-cluster"
}

#building template
data "template_file" "services" {
  template = file(var.flask_app_template_file)
  vars     = local.flask_ecs_services_vars
}

# ecs task definition
resource "aws_ecs_task_definition" "services" {
  family                   = "${var.environment}-${var.app_name}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.flask_app_cpu
  memory                   = var.flask_app_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.services.rendered

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_ecs_service" "flask_app_service" {
  name                       = "${var.environment}-${var.app_name}-service"
  cluster                    = aws_ecs_cluster.main.id
  task_definition            = aws_ecs_task_definition.services.arn
  desired_count              = var.desired_flask_task_count
  deployment_maximum_percent = 250
  launch_type                = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = var.app_name
    container_port   = 8000
  }

  depends_on = [
    # aws_lb_listener.https_forward,
    aws_iam_role_policy.ecs_task_execution_role,
  ]

  tags = {
    Environment = var.environment
    Application = "flask-app"
  }
}
