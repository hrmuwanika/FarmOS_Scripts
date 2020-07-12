#!/bin/bash

################################################################################
# Script for the installation of FarmOS using Docker
# Authors: Henry Robert Muwanika

# Make a new file:
# sudo nano install_farmos.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_farmos.sh
# Execute the script to install FarmOS:
# ./install_farmos.sh
#
################################################################################

#----------------------------------------------------
# Disable password authentication
#----------------------------------------------------
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config 
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service sshd restart

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n============= Update Server ================"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

#--------------------------------------------------
### Installation of Docker
#---------------------------------------------------
sudo apt remove docker docker-engine docker.io
sudo apt install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker

#-------------------------------------------------------------------------------------
# Installation of Docker compose
#-------------------------------------------------------------------------------------
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo mkdir farmOS
cd farmOS
wget https://raw.githubusercontent.com/farmOS/farmOS/7.x-1.x/docker/docker-compose.development.yml
wget https://raw.githubusercontent.com/farmOS/farmOS/7.x-1.x/docker/docker-compose.production.yml
sudo cp docker-compose.development.yml docker-compose.yml
#sudo cp docker-compose.production.yml docker-compose.yml
sudo docker-compose up -d

#----------------------------------------------------------------------------------------
echo "################################################################################"
echo "Visit http://the IP address in a browser"
echo "Database name: farm"
echo "Database username: farm"
echo "Database password: farm"
echo "Under "Advanced options", change "Database host" to: db"
#----------------------------------------------------------------------------------------
