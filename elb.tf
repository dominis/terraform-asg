resource "aws_elb" "asg-elb" {
  name    = "${var.name}"
  subnets = ["${split(",", var.public_subnets)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [
    "${aws_security_group.asg-elb.id}",
    "${aws_security_group.asg-node.id}",
  ]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}
