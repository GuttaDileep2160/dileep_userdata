#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

wget https://www.tooplate.com/zip-templates/2129_crispy_kitchen.zip -O 2129_crispy_kitchen.zip

sudo apt install unzip
unzip 2129_crispy_kitchen.zip 

cd /var/www/html
rm index.html 

# cp -rf /root/2129_crispy_kitchen/* /var/www/html/*  

cp -rf /2129_crispy_kitchen/* . 
