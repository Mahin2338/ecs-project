resource "aws_ecs_cluster" "main" {
  name = "umami-cluster"

tags = {
    Name = "umami-cluster"
    }

} 

resource "aws_iam_role" "ecs_execution" {
    name = "ecs-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })




}


resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-umami"
  retention_in_days = 7

  tags = {
    Name = "ecs-cloudwatch-logs"
  }
}


resource "aws_ecs_task_definition" "app" {
  family = "umami-tasks"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode ([{

    name = "umami"
    image = var.image_url
    

    portMappings = [{
        containerPort = 3000
        protocol = "tcp"
    }]

    environment = [{
        name = "DATABASE_URL"
        value = var.database_url

    }]

    logConfiguration = {
        logDriver = "awslogs"
        options = {
            "awslogs-group" = aws_cloudwatch_log_group.ecs.name
            "awslogs-region" = "eu-west-2"
            "awslogs-stream-prefix" = "ecs"
        }
    }





  }]) 

    tags = {
        Name = "umami"
    }

}


resource "aws_ecs_service" "app" {
    name = "umami-service"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count = 1
    launch_type = "FARGATE" 

    network_configuration {
      subnets = var.private_subnet_ids
      security_groups = var.ecs_security_group_id
      assign_public_ip = false
    }

    load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "umami"
    container_port   = 3000
    }
  tags = {
    Name = "umami-service"
  }
}