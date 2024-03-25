#!/bin/bash

################################################################################
# Script for the installation of FarmOS on Ubuntu 22.04
# Authors: Henry Robert Muwanika

# Make a new file:
# sudo nano install_farmos_ubuntu.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_farmos_ubuntu.sh
# Execute the script to install FarmOS:
# ./install_farmos_ubuntu.sh

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n============= Update Server ================"
sudo apt update && sudo apt -y upgrade 
sudo apt autoremove -y

#--------------------------------------------------
# Set up the timezones
#--------------------------------------------------
# set the correct timezone on ubuntu
timedatectl set-timezone Africa/Kigali
timedatectl

#----------------------------------------------------
# Disable password authentication
#----------------------------------------------------
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config 
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service sshd restart

#--------------------------------------------------
###  Install PHP8.1
#---------------------------------------------------
sudo apt install -y ca-certificates apt-transport-https software-properties-common 
sudo add-apt-repository ppa:ondrej/php  -y
sudo apt update

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
sudo apt install -y postgresql
sudo systemctl start postgresql && sudo systemctl enable postgresql

echo -e "\n=============== Creating the ODOO PostgreSQL User ========================="
sudo -u postgres psql
sudo -u postgres createdb farmdb
sudo -u postgres createuser farm_user
sudo -u postgres ALTER user farm_user with encrypted password 'farmospass';
sudo -u postgres ALTER DATABASE "farmdb" SET bytea_output = 'escape';
sudo -u postgres grant all privileges on database farmdb to farm_user;
sudo -u postgres \q

# Install Apache2 and Php8.2
sudo apt install -y apache2 libapache2-mod-php8.2 php8.2 php8.2-cli php8.2-pgsql php8.2-common php8.2-zip php8.2-bcmath \
php8.2-mbstring php8.2-xmlrpc php8.2-curl php8.2-soap php8.2-gd php8.2-xml php8.2-intl php8.2-ldap php8.2-imap php8.2-opcache unzip 

sudo systemctl enable apache2.service
sudo systemctl start apache2.service

sudo a2dismod mpm_event
sudo a2enmod mpm_prefork

sudo systemctl restart apache2

#----------------------------------------------------------------------------------------
# FarmOS Virtual host
#----------------------------------------------------------------------------------------

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/farmos.conf

sudo nano /etc/apache2/sites-available/farmos.conf

cd /usr/src
sudo wget https://github.com/farmOS/farmOS/releases/download/3.1.2/farmOS-3.1.2.tar.gz
sudo tar -zxvf farmOS-3.1.2.tar.gz

sudo mkdir /var/www/html/farmos
cd farmOS
cp -rf * /var/www/html/farmos

sudo chown -R www-data:www-data /var/www/html/farmos
sudo chmod -R 755 /var/www/html/farmos

sudo a2ensite farmos.conf
sudo a2dissite 000-default.conf

a2enmod rewrite

sudo systemctl reload apache2

#----------------------------------------------------------------------------------------

ufw allow 80/tcp
ufw allow 443/tcp


