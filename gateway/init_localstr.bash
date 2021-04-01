#!/bin/bash
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

# Installation and Setting up Supervisord
sudo apt-get -y install supervisor
mkdir -p $HOME/.supervisord
cd $HOME/.supervisord
wget -O supervisord.conf https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/localstr/supervisord.conf
wget -O pm2processes.config.js https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/localstr/pm2processes.config.js
sudo cp $HOME/.supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# mkdir -p $HOME/.localstr
# cd $HOME/.localstr
# rm -fR *
# git clone
# cd $HOME/.localstr/dv-gateway-streamer
# rm -fR node_modules package-lock.json
# npm install

#/usr/bin/supervisord -u $USER -c $HOME/.supervisord/supervisord.conf
