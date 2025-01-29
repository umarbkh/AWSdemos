# Prometheus EC2 Instance Setup with Terraform

This repository contains a Terraform configuration that provisions an EC2 instance with Prometheus installed via Ansible. The setup includes security groups, IAM roles, and necessary configurations to run Prometheus on an Amazon Linux 2 EC2 instance.

## How It Works

1. **User Data Installation**: The EC2 instance is configured with a user data script (`user_data.sh`), which installs **Ansible** on the instance and runs an **Ansible playbook** to install and configure **Prometheus**.
2. **Security Group**: The security group allows inbound traffic on ports `9090` (Prometheus), `80` (HTTP), and `22` (SSH).
3. **IAM Role**: The EC2 instance assumes an IAM role with **S3 read-only access** to allow fetching resources (like Ansible playbooks) from S3.

## Resources

- **Security Group**: Allows inbound traffic on the required ports.
- **IAM Role**: Grants the EC2 instance access to read from S3.
- **EC2 Instance**: A `t2.micro` instance running Amazon Linux 2.
- **IAM Instance Profile**: Associates the IAM role with the EC2 instance.

## Requirements

- Terraform
- AWS CLI configured with the correct IAM permissions
- S3 bucket containing the Ansible playbook (`prometheus.yaml`)

## Steps to Use

1. **Modify the AMI**: Update the `ami` field to match the appropriate Amazon Linux 2 AMI in your AWS region if necessary.
2. **Prepare User Data Script**: The user data script (`user_data.sh`) will install Ansible and execute the Ansible playbook to install Prometheus. Make sure to adjust the script for your specific needs.
3. **Prepare Ansible Playbook**: The playbook (`prometheus.yaml`) is responsible for installing and configuring Prometheus. Ensure this file is available in your S3 bucket under the specified path (`s3://umarbkh/awsdemos/prometheus.yaml`).
4. **Run Terraform**: Run the following commands to apply the Terraform configuration and launch the instance:

```bash
terraform init
terraform plan
terraform apply
terraform destroy #when done testing