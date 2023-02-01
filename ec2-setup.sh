#!/bin/bash
sudo -i
apt-get update
apt-get install apache2 -y
echo "<p> My Instance! </p>" > /var/www/html/index.html
systemctl restart apache2