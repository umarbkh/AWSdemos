# Define AWS provider with the region
provider "aws" {
  region = "us-east-1"  # Modify with your region
}

# Define security group to allow HTTP, SSH, and Prometheus ports
resource "aws_security_group" "allow_ports" {
  name        = "allow_prometheus_http_ssh"
  description = "Allow Prometheus, HTTP, and SSH"

  # Allow Prometheus web interface on port 9090
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access on port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define IAM role that EC2 instance will assume for S3 access
resource "aws_iam_role" "ec2_s3_role" {
  name               = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach S3 read-only access policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Define the EC2 instance for Prometheus
resource "aws_instance" "prometheus_ec2" {
  ami           = "ami-01816d07b1128cd2d"  # Replace with the appropriate AMI ID for Amazon Linux 2
  instance_type = "t2.micro"  # Instance type (smallest option for testing)

  # Attach security group and IAM instance profile
  security_groups = [aws_security_group.allow_ports.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # User data script to install Ansible and run the playbook for Prometheus installation
  user_data = file("user_data.sh")

  tags = {
    Name = "Prometheus EC2 Instance"
  }
}

# Create an IAM instance profile to associate the role with the EC2 instance
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_access_profile"
  role = aws_iam_role.ec2_s3_role.name
}

# Output Prometheus web UI URL after EC2 instance is running
output "prometheus_url" {
  value = "http://${aws_instance.prometheus_ec2.public_ip}:9090"
  description = "The URL to access Prometheus web interface"
}

# Output public DNS of the EC2 instance
output "public_dns" {
  value = aws_instance.prometheus_ec2.public_dns
}
