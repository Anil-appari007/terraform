###########################################
#######   Target Group
###########################################
resource "aws_lb_target_group" "front_end_tg" {
  name     = "application-front"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  # health_check {
  #   enabled = true
  #   healthy_threshold = 5
  #   interval = 15
  #   matcher = "200"
  #   path = "/"
  #   port = "traffic-port"
  #   protocol = "HTTP"
  #   timeout = 10
  #   unhealthy_threshold = 3
  # }
}

###########################################
#######   Attach EC2 to Target Group
###########################################
resource "aws_lb_target_group_attachment" "attach_lb_tg" {
  count = var.public_instance_count
  target_group_arn = aws_lb_target_group.front_end_tg.arn
  target_id        = aws_instance.public-ec2[count.index].id
  port             = 80
}

###########################################
#######   Load Balancer
###########################################
resource "aws_lb" "frontend_lb" {
  name               = "front"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_443.id,aws_security_group.allow_80.id]

  subnets            = [for each in aws_subnet.public-subnet: each.id]

  enable_deletion_protection = false

  tags = {
    "Name" = "${var.environment}-alb"
    "Environment" = "${var.environment}"
  }
}

###########################################
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.frontend_lb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end_tg.arn
#   }
# }

###########################################
#######   HTTP to HTTPS redirection
###########################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend_lb.arn
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

###########################################
#######   HTTPS 
###########################################
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert_for_https.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end_tg.arn
  }
}
###########################################
#######   attach DNS to Load Balancer
###########################################
resource "aws_route53_record" "record_for_alb" {
  zone_id = var.dns_zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.frontend_lb.dns_name
    zone_id                = aws_lb.frontend_lb.zone_id
    evaluate_target_health = true
  }
}