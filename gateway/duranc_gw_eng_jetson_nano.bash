#!/bin/bash

###---Bash file to setup Dockerized Duranc Gateway and Analytics Engine with Auto Updater in Jetson Nano---###
sudo ls

# Check for sudo permission duplicate entry in sudoers file
FILE_TO_CHECK_1="/etc/sudoers"
STRING_TO_CHECK_1="$USER ALL=(ALL) NOPASSWD:ALL"
if  sudo grep -q "$STRING_TO_CHECK_1" "$FILE_TO_CHECK_1" ; then
	echo 'sudo permission entry exists in sudoers file' ;
else
	## Add Sudo permision to gwuser
	echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers >/dev/null
fi

# Install docker compose software
sudo apt-get install -y docker-compose gnupg2 pass
echo "c6356d49-4f26-43f0-890c-75aceb6fc3ca" > $HOME/.pwd.txt
cat $HOME/.pwd.txt | docker login --username durancai --password-stdin

#Create a link for docker config
ln -s $HOME/.docker/config.json $HOME/.docker/auth.json

#Create docker volumes for persistent storage
docker volume create --name=stg-gw-files
docker volume create --name=stg-motion-files
docker volume create --name=stg-engine-files

#Download docker compose file
wget -O $HOME/.dur-gw-eng-jetson-nano.yml https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/doc-comp-gw-eng-jetson-nano.yml

# Build docker containers
docker-compose -f $HOME/.dur-gw-eng-jetson-nano.yml up -d

# Show running container
clear
docker ps -a
