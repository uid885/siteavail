#!/bin/bash -
##########################################################
# Author:      Christo Deale                  
# Date  :      2023-07-05                
# siteavail :  Utility to ping from a list and if nodes
#              are down notify via email using sendmail
##########################################################
# Check if Sendmail is installed
if ! command -v sendmail &> /dev/null; then
    echo "Sendmail is not installed. Installing Sendmail, m4, and s-nail..."
    sudo dnf install -y sendmail sendmail-cf m4 s-nail
fi

# Prompt for email address
read -p "Enter your email address: " email_address

# Prompt for SMTP mail server
read -p "Enter your SMTP mail server: " smtp_server

# Uncomment and modify SMART_HOST in sendmail.mc
sudo sed -i '/^dnl define(`SMART_HOST/ s/^dnl //' /etc/mail/sendmail.mc
sudo sed -i "s/smtp.your.provider/$smtp_server/" /etc/mail/sendmail.mc

# Generate new sendmail.cf
sudo m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

# Restart Sendmail service
sudo systemctl restart sendmail

# Ping nodes from serverlist.txt
while IFS= read -r node; do
    if ! ping -c 1 "$node" &> /dev/null; then
        echo "Node $node is down" | sendmail -v "$email_address"
    fi
done < serverlist.txt
