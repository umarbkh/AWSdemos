#!/bin/bash

# Exit on any error
set -e

# Update system packages
yum update -y

# Remove any existing httpd installation
yum -y remove httpd httpd-tools

# Install the required packages (httpd, php)
yum install -y httpd

# Start and enable Apache (httpd) service
systemctl start httpd
systemctl enable httpd

# Add ec2-user to the apache group and set directory permissions
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Create a simple HTML page with instance ID and "Hello"
echo "<html><body><h1>Hello, Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h1></body></html>" > /var/www/html/index.html
