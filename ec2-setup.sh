#!/bin/bash
apt-get update
apt-get install -y apache2
sed -i -e 's/80/8080/' /etc/apache2/ports.conf
echo "<h1>Fortune cookie app coming soon!</h1>" > /var/www/html/index.html
systemctl restart apache2