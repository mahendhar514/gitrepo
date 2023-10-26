#!/bin/bash
sudo ls
NODE_VERSION=12.10.0
sudo apt purge nodejs -y
sudo rm -r /usr/lib/node_modules
sudo apt-get install -y curl git wget

# Set up the NVM_DIR variable and clone the NVM repository from a given branch.
export NVM_DIR="$HOME/.nvm" && (
git clone -b v0.32.1 https://portal.duranc.com/git/nvm.git "$NVM_DIR"
) && \. "$NVM_DIR/nvm.sh"

# Define the lines we want to ensure are in ~/.bashrc for NVM initialization.
NVM_LINES=(
	'export NVM_DIR="$HOME/.nvm"'
	'[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm'
)

# Loop through each line and append it to ~/.bashrc if it's not already present.
for LINE in "${NVM_LINES[@]}"; do
	grep -qF -- "$LINE" ~/.bashrc || echo "$LINE" >> ~/.bashrc
done

source $HOME/.bashrc

nvm install $NODE_VERSION
nvm use v$NODE_VERSION
nvm alias default v$NODE_VERSION

nodejs --version
npm --version

npm install -g node-gyp
npm install -g pm2
pm2 update
pm2 install pm2-logrotate
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
sudo ln -s "$(which npm)" /usr/bin/npm

