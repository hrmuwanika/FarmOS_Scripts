#!/bin/bash

### Installation of FarmOS 

sudo apt-get update && sudo apt-get -y upgrade
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-cache policy docker-ce
sudo apt-get install -y docker-ce 
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version

sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo mkdir farmOS
cd farmOS
wget https://raw.githubusercontent.com/farmOS/farmOS/7.x-1.x/docker/docker-compose.development.yml

sudo cp docker-compose.development.yml docker-compose.yml
sudo docker compose up

# Visit the IP address in a browser - you should see the Drupal/farmOS installer.

# Database setup
# In the "Set up database" step of installation, use the following values:

# Database name: farm
# Database username: farm
# Database password: farm
# Under "Advanced options", change "Database host" to: db

docker-compose start
docker-compose stop
