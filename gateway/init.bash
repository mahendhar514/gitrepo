#!/bin/bash

# Packages
sudo apt-get -y install ffmpeg python3-pip ipython3 libatlas-base-dev arp-scan libxml++2.6-dev libxslt1-dev autossh python3-numpy
    
# In order to scan more efficiently cameras, let's allow normal user to do arp scanning:    
sudo chmod u+s /usr/sbin/arp-scan
    
# For systemd daemonization to work for non-root users, do:
sudo adduser $USER systemd-journal
sudo loginctl enable-linger $USER

# This has given problems many times: should be in the default path, but many times, is not
# Enable it right now
export PATH=$PATH:$HOME/.local/bin

# If you're running this manually, just see that the above line is in your .bashrc 
# ..and that your run it *now*

# The following is automagic fixing of the problem (don't do this manually):


### add path to environmental variable
# Remove anything we might have added earlier to .bashrc
grep -v "<DURANC>" $HOME/.bashrc > $HOME/.tmp_bashrc
# Add the path to .bashrc
echo "export PATH=\$PATH:\$HOME/.local/bin # <DURANC>" >> $HOME/.tmp_bashrc
cp -f $HOME/.tmp_bashrc $HOME/.bashrc

### add line "Storage=persistent" to "/etc/systemd/journald.conf"
fname="/etc/systemd/journald.conf"
tmp="/tmp/journald.conf.tmp"
add="Storage=persistent"
# remove duranc specific stuff => tmpfile
sudo grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
sudo echo $add" # <DURANC>" >> $tmp
# tmpfile to final file
sudo cp -f $tmp $fname
