#!/bin/bash

# Packages
sudo apt-get -y install python3-pip ipython3 python3-numpy python3-opencv

# For systemd daemonization to work for non-root users, do:
sudo adduser $USER systemd-journal
sudo loginctl enable-linger $USER

# This has given problems many times: should be in the default path, but many times, is not
# Enable it right now
export PATH=$PATH:$HOME/.local/bin

# If you're running this manually, just see that the above line is in your .bashrc 
# ..and that your run it *now*

# The following is automagic fixing of the problem (don't do this manually):

# Remove anything we might have added earlier to .bashrc
grep -v "<DURANC>" $HOME/.bashrc > $HOME/.tmp_bashrc
# Add the path to .bashrc
echo "export PATH=\$PATH:\$HOME/.local/bin # <DURANC>" >> $HOME/.tmp_bashrc
cp -f $HOME/.tmp_bashrc $HOME/.bashrc
