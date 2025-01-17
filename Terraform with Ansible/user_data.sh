#!/bin/bash

# Exit on any error
set -e

# Update the system
#yum update -y


# Install Ansible
sudo yum install -y ansible

# Set up the S3 link for the playbook
S3_PLAYBOOK_URL="s3://umarbkh/playbook.yaml"

# Download the playbook from the S3 URL
aws s3 cp $S3_PLAYBOOK_URL /tmp/playbook.yaml

# Run the Ansible playbook
ansible-playbook /tmp/playbook.yaml
