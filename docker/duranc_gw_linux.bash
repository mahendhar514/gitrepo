#!/bin/bash

###---Bash file to setup Dockerized Duranc Gateway with Auto Updater in Linux---###
sudo ls

sudo apt-get install -y docker-compose

ln -s $HOME/.docker/config.json $HOME/.docker/auth.json

docker volume create gw-files
docker volume create motion-files

wget -O $HOME/docker-compose-gateway-linux.yml https://github.com/DurancOy/duranc_bootstrap/blob/master/docker/docker-compose-gateway-linux.yml

docker-compose -f $HOME/docker-compose-gateway-linux.yml up -d

clear
docker ps -a
