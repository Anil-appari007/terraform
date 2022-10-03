#######################################################
resource "aws_lb_target_group" "front" {
  name     = "application-front"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    enabled = true
    healthy_threshold = 5
    interval = 15
    matcher = 200
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 10
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "attach_lb_tg" {
  count = var.public_instance_count
  target_group_arn = aws_lb_target_group.front.arn
  target_id        = aws_instance.public-ec2[count.index].id
  port             = 80
}
resource "aws_lb" "front" {
  name               = "front"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_80.id]

  subnets            = [for each in aws_subnet.public-subnet: each.id]

  enable_deletion_protection = false

  tags = {
    "Name" = "${var.environment}-alb"
    "Environment" = "${var.environment}"
  }
}
output "alb_dns" {
    value = aws_lb.front.dns_name
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

############################################