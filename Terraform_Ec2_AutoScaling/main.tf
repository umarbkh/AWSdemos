provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create two subnets in different AZs for the Load Balancer and Auto Scaling Group
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true  # Ensure public IP assignment on launch
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true  # Ensure public IP assignment on launch
}

# Create an internet gateway to allow internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create route table and associate it with the subnets to make them public
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

# Create a route to allow internet traffic (0.0.0.0/0 -> IGW)
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate route table with subnets
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt.id
}

# Create a security group for Load Balancer and instances
resource "aws_security_group" "sg" {
  name        = "lb-web-sg"
  description = "Allow all inbound HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.main.id

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
}

# Create Launch Template with user data to install Apache
resource "aws_launch_template" "lt" {
  name_prefix   = "lt-example"
  image_id      = "ami-01816d07b1128cd2d"  # Specified AMI
  instance_type = "t2.micro"               # Free Tier eligible

  network_interfaces {
    security_groups = [aws_security_group.sg.id]
  }

  # User data to install and start Apache (httpd) from external file
  user_data = base64encode(file("user_data.sh"))
}

# Create Target Group for Load Balancer
resource "aws_lb_target_group" "tg" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type          = "ELB"
  health_check_grace_period = 300  # Allow time for the instances to warm up
}

# Create an Application Load Balancer
resource "aws_lb" "lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

# Load Balancer Listener for HTTP (Port 80)
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Output Load Balancer DNS (URL)
output "load_balancer_url" {
  value       = aws_lb.lb.dns_name
  description = "The DNS name of the Load Balancer to access the web server"
}

