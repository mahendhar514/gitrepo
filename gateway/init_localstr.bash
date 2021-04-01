#!/bin/bash

FILEDIRECTORY_LOCALSTR=$HOME/.localstr
LOCALSTR_FILE=index.js

if [ ! -e $FILEDIRECTORY_LOCALSTR/$LOCALSTR_FILE ]
then
	# Local Streamer Installation
	sudo apt update
	sudo apt install curl -y
	sudo apt autoremove -y
	sudo chown -R $USER:$USER /usr/lib/node_modules
	curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
	sudo apt install nodejs -y

	nodejs --version
	npm --version

	# Install PM2
	sudo npm install -g node-gyp
	sudo npm install -g pm2
	pm2 install pm2-logrotate
	pm2 set pm2-logrotate:retain 7
	pm2 set pm2-logrotate:compress true
else
    echo 'Node and NPM Already Installed....'
fi
