#!/bin/bash

################################################################################
# Script for the installation of FarmOS on Ubuntu 22.04
# Authors: Henry Robert Muwanika

# Make a new file:
# sudo nano install_farmos.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_farmos.sh
# Execute the script to install FarmOS:
# ./install_farmos.sh
#

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

# Install mariadb databases
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mariadb.mirror.liquidtelecom.com/repo/10.11/ubuntu jammy main'
sudo apt update

#--------------------------------------------------
### Installation of LAMP
#---------------------------------------------------
# Install PHP8.1
sudo apt install ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php  -y
sudo apt update

# Install LAMP Server
sudo apt install -y apache2 mariadb-server mariadb-client libapache2-mod-php8.1 php8.1 php8.1-cli php8.1-mysql php8.1-common php8.1-zip \
php8.1-mbstring php8.1-xmlrpc php8.1-curl php8.1-soap php8.1-gd php8.1-xml php8.1-intl php8.1-ldap php8.1-imap php8.1-opcache unzip 

sudo systemctl enable apache2.service
sudo systemctl start apache2.service

sudo a2dismod mpm_event
sudo a2enmod mpm_prefork

sudo systemctl restart apache2

# sudo mysql_secure_installation

sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

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

sudo mysql -u root << MYSQL_SCRIPT
CREATE DATABASE farmdb;
CREATE USER 'farm_user'@'localhost' IDENTIFIED BY 'm0d1fyth15';
GRANT ALL PRIVILEGES ON farmdb.* TO 'farm_user'@'localhost';
FLUSH PRIVILEGES;
exit
MYSQL_SCRIPT

ufw allow 80/tcp
ufw allow 443/tcp


