#!/bin/bash

# Exit on any error
set -e

# Update system packages
#yum update -y


# Install the required packages (httpd, php)
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Add ec2-user to the apache group and set directory permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;

# Create a simple HTML page with instance ID and "Hello"
sudo echo "<html><body><h1>Hello World</h1></body></html>" > /var/www/html/index.html
