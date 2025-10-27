
resource "aws_lb" "main" {
  name = "umami-lb"
  load_balancer_type = "application"
  security_groups = [var.alb_security_group_id]
  subnets = var.public_subnets_id

tags = {
  Name = "umami-lb"
}


}


resource "aws_lb_target_group" "app" {
  name = "umami-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/heartbeat"
    protocol            = "HTTP"
    matcher             = "200"
  }
    deregistration_delay = 30

    tags = {
        Name = "umami-tg"
    }
  
}


resource "aws_lb_listener" "http" {

    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }

tags = {
  Name = "umami-listener"
}

}