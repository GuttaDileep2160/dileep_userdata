#!/bin/bash

apt-get update && apt-get install apache2 -y
apt-get update && apt-get install unzip -y
echo $(pwd)
mkdir /root/project
cd /root/project/
ls /root/project/
wget  https://www.tooplate.com/zip-templates/2129_crispy_kitchen.zip
echo $(pwd)
cd /root/project/
unzip 2129_crispy_kitchen.zip
cd /var/www/html/
rm -rf index.html
cp -rf /root/project/2129_crispy_kitchen/* .
