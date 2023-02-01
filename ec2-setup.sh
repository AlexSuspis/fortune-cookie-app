#!/bin/bash
apt-get update
apt-get install -y git
git clone https://github.com/AlexSuspis/fortune-cookie-app.git
cd fortune-cookie-app
npm install
node app.js