# EC2 Instance with SSM Setup Demo

This Terraform configuration demonstrates setting up an EC2 instance with SSM (Systems Manager) access and essential configurations. 
Ansible is also used to install a webserver and confige Cloud watch agent to push necessary metrices to Cloud Watch. 

## Components

1. **Providers**
   - AWS for infrastructure setup.
   - Random for consistent resource naming.

2. **Random Pet**
   - Generates unique, consistent resource names tied to the provided `ami_id`.

3. **IAM Role and Policy**
   - Allows EC2 instances to interact with AWS SSM using `AmazonSSMManagedInstanceCore` policy.

4. **IAM Instance Profile**
   - Links the IAM role to the EC2 instance.

5. **EC2 Instance**
   - Configures the instance with user data for initialization and links to the IAM instance profile.

6. **Security Group**
   - Ensures secure access with HTTP (port 80) and SSH (port 22) ingress rules.

7. **Ansible Playbook**
    - Ansible playbook (playbook.yaml) is downloaded from S3 and used to install and configure a Web server and Cloud watch agent.


## Prerequisites

- AWS CLI configured with appropriate permissions.
- Terraform installed.

## How to Use

1. Replace the placeholder AMI ID if needed, current ami is a t2 micro free tier.
2. Ensure `user_data.sh` is present.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Preview the infrastructure changes:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Notes

- Update security group rules to match your access requirements.
- Verify SSM setup by testing the connection through the AWS Management Console or CLI.
- Replace https with http in the browser, SSL is not part of this demo.
- Make sure to run 'terraform destroy' to remove all resources.
