#!/bin/bash

# Exit on any error
set -e

# Install Ansible
sudo yum install -y ansible

# Set up the S3 link for the playbook
S3_PLAYBOOK_URL="s3://umarbkh/awsdemos/terraform_cicd.yaml"

# Download the playbook from the S3 URL
aws s3 cp $S3_PLAYBOOK_URL /tmp/terraform_cicd.yaml

# Run the Ansible playbook
ansible-playbook /tmp/terraform_cicd.yaml  
