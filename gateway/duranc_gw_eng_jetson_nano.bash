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

# check for swap entry in fstab
SWPFILE_TO_CHECK="/etc/fstab"
SWPSTRING_TO_CHECK="/mnt/6GB.swap"
if  sudo grep -q "$SWPSTRING_TO_CHECK" "$SWPFILE_TO_CHECK" ; then
	echo 'swap increase entry is updated' ;
else
	# Add 6GB of swap memory in Jetson
	sudo fallocate -l 6G /mnt/6GB.swap
	sudo mkswap /mnt/6GB.swap
	sudo chmod 600 /mnt/6GB.swap
	sudo swapon /mnt/6GB.swap
	echo "/mnt/6GB.swap  none  swap  sw 0  0" | sudo tee -a /etc/fstab >/dev/null
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
