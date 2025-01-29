#!/bin/bash

# Exit on any error
set -e

# Update the system
yum update -y

# Install Ansible
sudo yum install -y ansible

# Set up the S3 link for the playbook
S3_PLAYBOOK_URL="s3://umarbkh/awsdemos/prometheus.yaml"

# Download the playbook from the S3 URL
sudo aws s3 cp $S3_PLAYBOOK_URL /tmp/prometheus.yaml

# Create an inventory file
sudo cat <<EOL > /tmp/inventory.ini
[local]
localhost ansible_connection=local
EOL

# Run the Ansible playbook with the inventory file
sudo ansible-playbook -i /tmp/inventory.ini /tmp/prometheus.yaml
