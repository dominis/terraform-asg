# This is the sg for the elb
resource "aws_security_group" "asg-elb" {
  name = "${var.name}-asg-elb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-asg-elb-sg"
  }
}

resource "aws_security_group" "asg-node" {
  name = "${var.name}-asg-node-sg"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "77.251.245.93/32",  # dominis home
      "185.68.240.100/32", # dominis office
      "193.225.234.1/32",  # ber office
      "89.133.37.56/32",   # ber home
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-asg-node-sg"
  }
}
