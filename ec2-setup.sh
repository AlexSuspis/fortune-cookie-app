#!/bin/bash
sudo -i
apt-get update
apt-get install apache2 -y
sudo -i
echo "<p> My Instance! </p>" > /var/www/html/index.html
sudo -i
systemctl restart apache2