# Auto Scaling Setup Demo

This demo Terraform configuration sets up a load balancer with an auto-scaling infrastructure on AWS. Below are the components and their purposes:

## Components

1. **VPC**
   - Defines a Virtual Private Cloud (VPC) with DNS support and hostnames enabled for network isolation.

2. **Subnet**
   - Creates a public subnet within the VPC to host resources accessible from the internet.

3. **Security Group**
   - Configures ingress and egress rules to allow HTTP (port 80) and SSH (port 22) traffic.

4. **Instance Profile**
   - Links the IAM role to EC2 instances via an instance profile.

5. **Launch Template**
   - Defines the template for EC2 instances, specifying instance type, AMI, and user data.

6. **Auto Scaling Group**
   - Automatically adjusts the number of instances between the defined min and max size based on demand.

7. **Load Balancer**
   - Distributes incoming traffic across the instances in the Auto Scaling Group and performs health checks.

8. **Output**
   - Displays the ELB DNS, Copy/Paste this in browser with "http://".

## Prerequisites

- AWS CLI configured with appropriate credentials.
- Terraform installed on your system.

## How to Use

1. Replace placeholders (e.g., AMI ID) with actual values.
2. Ensure `user_data.sh` is present in the working directory.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Preview the changes:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Notes

- Adjust the Auto Scaling Group's `min_size`, `max_size`, and `desired_capacity` to suit your requirements.
- Review security group ingress rules to match your specific access needs.
- in the browser make sure to access with http and not https, SSL is not part of this demo.
- Make sure to run 'terraform destroy' to remove all resources later.

