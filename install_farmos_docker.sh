#!/bin/bash

################################################################################
# Script for the installation of FarmOS using Docker
# Authors: Henry Robert Muwanika

# Make a new file:
# sudo nano install_farmos_docker.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_farmos_docker.sh
# Execute the script to install FarmOS:
# ./install_farmos_docker.sh
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
# Remove older versions of docker
sudo apt remove -y docker docker-engine docker.io containerd runc

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io 
sudo systemctl start docker && sudo systemctl enable docker

#----------------------------------------------------------------------------------------
# Installation of Docker compose
#----------------------------------------------------------------------------------------
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

#----------------------------------------------------------------------------------------
# FarmOS Production
#----------------------------------------------------------------------------------------
cd /usr/src/
git clone https://github.com/farmOS/farmOS.git
cd farmOS/docker
sudo cp docker-compose.production.yml docker-compose.yml
sudo docker-compose up -d
#----------------------------------------------------------------------------------------

echo "################################################################################"
echo "Open your browser http://IPaddress"
echo "Database name: farm"
echo "Database username: farm"
echo "Database password: farm"
echo "Under "Advanced options", change "Database host" to: db"
echo "################################################################################"
#----------------------------------------------------------------------------------------


