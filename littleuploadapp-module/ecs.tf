resource "aws_ecs_cluster" "webserver_cluster" {
  name = "littleupload-webserver-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "web_service" {
  name                 = "web_service"
  cluster              = aws_ecs_cluster.webserver_cluster.id
  task_definition      = aws_ecs_task_definition.webserver.arn
  desired_count        = 3
  launch_type          = "FARGATE"
  force_new_deployment = true
  platform_version     = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target.arn
    container_name   = "webserver"
    container_port   = 5000
  }
}

resource "aws_ecs_task_definition" "webserver" {
  family                = "webserver"
  container_definitions = <<EOF
[
  {
    "portMappings": [
      {
        "hostPort": 5000,
        "protocol": "tcp",
        "containerPort": 5000
      }
    ],
    "cpu": 512,
    "environment": [
      {
        "name": "S3-BUCKET",
        "value":"files.${var.root_domain}"
      },
      {
        "name":"POST_LMBDA_URL",
        "value": "api.${var.root_domain}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.ecs.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "memory": 1024,
    "image": "${var.image}",
    "essential": true,
    "name": "webserver"
  }
]
EOF

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = aws_iam_role.ecs_role.arn

  tags = {
    Terraform = "True"
  }
}

# Need target group
# Register target group targets
# Load balancer
# Listener for lb
# auto scaling target
# auto scaling policy
# need security group for port 5000 with no ssh
# need security group for the lb with port 80 and 443
# get lb back for CNAME record to poring.xyz
# need AWSServiceRoleForECS


resource "aws_security_group" "ecs" {
  name   = "webapp-ecs-security-group"
  vpc_id = aws_vpc.littleupload-vpc.id
}

resource "aws_security_group_rule" "allow_flask_port" {
  type              = "ingress"
  security_group_id = aws_security_group.ecs.id

  from_port   = 5000
  to_port     = 5000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_flask_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.ecs.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group" "elb" {
  name   = "webapp-elb-security-group"
  vpc_id = aws_vpc.littleupload-vpc.id
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.elb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_alb_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.elb.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.elb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_lb" "web_ecs_load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.elb.id]
  # internal = true switch when refactored to have no public IP addresses
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_ecs_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_ecs_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.lb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target.arn
  }
}

resource "aws_lb_target_group" "ecs_target" {
  name        = "ecs-target"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.littleupload-vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = {
    Terraform = "True"
  }
}

resource "aws_appautoscaling_target" "to_containers" {
  max_capacity       = 6
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.webserver_cluster.name}/${aws_ecs_service.web_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_for_webcluster" {
  name               = "memory_for_webcluster"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.to_containers.resource_id
  scalable_dimension = aws_appautoscaling_target.to_containers.scalable_dimension
  service_namespace  = aws_appautoscaling_target.to_containers.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "cpu_for_webcluster" {
  name               = "cpu_for_webcluster"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.to_containers.resource_id
  scalable_dimension = aws_appautoscaling_target.to_containers.scalable_dimension
  service_namespace  = aws_appautoscaling_target.to_containers.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
