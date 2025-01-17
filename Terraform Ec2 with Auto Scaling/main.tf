# Define a VPC with DNS support and hostnames enabled
resource "aws_vpc" "autoscale_test_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "autoscale-test-vpc"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "autoscale_test_subnet" {
  vpc_id                  = aws_vpc.autoscale_test_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "autoscale-test-subnet"
  }
}

# Define a security group with ingress and egress rules
resource "aws_security_group" "autoscale_test_sg" {
  vpc_id = aws_vpc.autoscale_test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "autoscale-test-sg"
  }
}

# Create an IAM role for EC2 with an assume role policy
resource "aws_iam_role" "autoscale_test_ec2_role" {
  name = "autoscale_test_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to the IAM role for lifecycle actions
resource "aws_iam_role_policy" "autoscale_test_ec2_policy" {
  name   = "EC2LifecyclePolicy"
  role   = aws_iam_role.autoscale_test_ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "autoscaling:CompleteLifecycleAction",
        Resource = "*"
      }
    ]
  })
}

# Create an instance profile for the IAM role
resource "aws_iam_instance_profile" "autoscale_test_instance_profile" {
  name = "autoscale_test_instance_profile"
  role = aws_iam_role.autoscale_test_ec2_role.name
}

# Define a launch template for EC2 instances
resource "aws_launch_template" "autoscale_test_lt" {
  name          = "autoscale-test-lt"
  image_id      = "ami-01816d07b1128cd2d" 
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.autoscale_test_instance_profile.name
  }

  user_data = base64encode(file("user_data.sh"))
}

# Set up an Auto Scaling Group with desired capacity
resource "aws_autoscaling_group" "autoscale_test_asg" {
  launch_template {
    id      = aws_launch_template.autoscale_test_lt.id
    version = "$Latest"
  }

  min_size = 1
  max_size = 3
  desired_capacity = 2

  vpc_zone_identifier = [aws_subnet.autoscale_test_subnet.id]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "autoscale-instance"
    propagate_at_launch = true
  }
}

# Create a classic load balancer for the Auto Scaling Group
resource "aws_elb" "autoscale_test_clb" {
  name               = "autoscale-test-clb"
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  instances = aws_autoscaling_group.autoscale_test_asg.id

  tags = {
    Name = "autoscale-test-clb"
  }
}

# Output the public IPs of EC2 instances
output "ec2_public_ips" {
  value = aws_instance.autoscale_test_clb.*.public_ip
}
