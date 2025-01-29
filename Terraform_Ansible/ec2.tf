# Launch an EC2 instance with IAM role and initialization
resource "aws_instance" "web" {
  ami           = "ami-01816d07b1128cd2d"  # Replace with your AMI ID
  instance_type = "t2.micro"

  user_data     = file("user_data.sh")
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name  # Use the instance profile here

  tags = {
    Name = "ec2-learn-${random_pet.name.id}"
  }

  metadata_options {
    http_tokens               = "optional"  # Ensure IMDSv2 is enabled
    http_endpoint             = "enabled"
    http_put_response_hop_limit = 2
  }
}

# Define a Security Group for the EC2 instance
resource "aws_security_group" "web_sg" {
  name = "${random_pet.name.id}-sg"

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
}
