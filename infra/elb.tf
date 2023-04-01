resource "aws_security_group" "alb" {
  name_prefix = "alb-"
  vpc_id      = module.vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "k8s-alb" {
  name               = "k8s-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.private_subnet_ids

  tags = {
    Name = "k8s-alb"
  }
}

resource "aws_lb_listener" "serve-listener" {
  load_balancer_arn = aws_lb.k8s-alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.serve-target.arn
  }

  port     = 80
  protocol = "HTTP"
}

resource "aws_lb_target_group" "serve-target" {
  name_prefix = "serve-"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "serve-target" {
  count            = length(module.k8s.worker_node_ids)
  target_group_arn = aws_lb_target_group.serve-target.arn
  target_id        = module.k8s.worker_node_ids[count.index]
  port             = 3000
}
