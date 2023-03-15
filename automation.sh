#!/bin/bash
# Set variables
s3_bucket="upgrad-vyankatesh"
myname="Vyankatesh"
timestamp=$(date '+%d%m%Y-%H%M%S')
# Update package details and package list
sudo apt update -y
# Install apache2 if it is not already installed
if ! dpkg -s apache2 >/dev/null 2>&1; then
    sudo apt install apache2 -y
fi
# Ensure that apache2 service is running and enabled
if ! systemctl is-active --quiet apache2; then
    sudo systemctl start apache2
fi
if ! systemctl is-enabled --quiet apache2; then
    sudo systemctl enable apache2
fi
# Create tar archive of apache2 access logs and error logs
cd /var/log/apache2
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar $(find . -name "*.log" -type f)
# Copy archive to S3 bucket using AWS CLI
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

