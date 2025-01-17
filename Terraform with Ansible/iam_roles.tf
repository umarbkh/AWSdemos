# Generate a random pet name for consistent resource naming
resource "random_pet" "name" {
  keepers = {
    ami_id = "ami-01816d07b1128cd2d"
  }
}

# IAM Role for EC2 to allow access to SSM
resource "aws_iam_role" "ssm_role" {
  name = "MySSMRole-${random_pet.name.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "MySSMInstanceProfile-${random_pet.name.id}"
  role = aws_iam_role.ssm_role.name
}
