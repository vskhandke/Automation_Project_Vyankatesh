#!/bin/bash
# Set variables
s3_bucket="upgrad-vyankatesh"
myname="Vyankatesh"
timestamp=$(date '+%d%m%Y-%H%M%S')
inventory_file="/var/www/html/inventory.html"
log_type="httpd-logs"
log_file="/tmp/${myname}-httpd-logs-${timestamp}.tar"
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
tar -cvf "${log_file}" $(find . -name "*.log" -type f)
# Copy archive to S3 bucket using AWS CLI
aws s3 cp "${log_file}" "s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar"
# Bookkeeping
if [ ! -e "${inventory_file}" ]; then
  echo -e "Log Type\t\tDate Created\t\tType\t\tSize" > "${inventory_file}"
fi
size=$(du -h "${log_file}" | awk '{print $1}')
echo -e "${log_type}\t\t${timestamp}\t\ttar\t\t${size}" >> "${inventory_file}"
# Create cron job file
cron_file="/etc/cron.d/automation"
cron_command="0 0 * * * root /root/Automation_Project_Vyankatesh/automation.sh"
if [ ! -e "${cron_file}" ]; then
  echo "${cron_command}" > "${cron_file}"
  chmod 644 "${cron_file}"
fi
