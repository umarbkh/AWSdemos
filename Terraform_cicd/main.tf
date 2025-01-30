provider "aws" {
  region = "us-east-1"
}

# 🔹 VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "TerraformVPC" }
}

# 🔹 Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "PublicSubnet" }
}

# 🔹 Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "PrivateSubnet" }
}

# 🔹 Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "IGW" }
}

# 🔹 Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "PublicRouteTable" }
}

# 🔹 Associate Public Route Table with Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 🔹 Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Jenkins
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 Security Group for RDS (Only accessible from EC2)
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306  # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  # Allow only from Public Subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EC2 Instance (Free Tier)
resource "aws_instance" "web_server" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"  # Free tier eligible instance
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = file("user_data.sh")  # Reference the external user_data.sh file

  tags = { Name = "Terraform-EC2" }
}

# 🔹 RDS Database (Free Tier)
resource "aws_db_instance" "rds_db" {
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"  # Free tier eligible instance type
  db_name             = "terraformdb"
  username            = "admin"
  password            = "Terraform@123"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = { Name = "TerraformRDS" }
}

# 🔹 RDS Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]
  tags = { Name = "DBSubnetGroup" }
}

# 🔹 Output EC2 Public URL
output "ec2_public_url" {
  value = "http://${aws_instance.web_server.public_ip}:8080"
  description = "The public URL for the EC2 instance running Jenkins (HTTP port 8080)"
}

# 🔹 Output RDS Status
output "rds_status" {
  value = "RDS instance '${aws_db_instance.rds_db.db_name}' is ready!"
  description = "A message indicating that the RDS instance is ready"
}
