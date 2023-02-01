# #!/bin/bash
# apt-get update
# apt-get install -y git
# git clone https://github.com/AlexSuspis/fortune-cookie-app.git
# cd fortune-cookie-app
# npm install
# node app.js
sudo su
yum -y install httpd
echo "<p> My Instance! </p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd -p 8080