#!/bin/bash

# Packages
sudo apt-get -y install python3-pip ipython3 python3-numpy python3-opencv

# For systemd daemonization to work for non-root users, do:
sudo adduser $USER systemd-journal
sudo loginctl enable-linger $USER

# disable local firewall: now other linux boxes in the LAN can access the stream via tcp
systemctl disable ufw.service

# This has given problems many times: should be in the default path, but many times, is not
# Enable it right now
export PATH=$PATH:$HOME/.local/bin

# If you're running this manually, just see that the above line is in your .bashrc 
# ..and that your run it *now*

# The following is automagic fixing of the problem (don't do this manually):

### complement the path to have $HOME/.local/bin
fname=$HOME"/.bashrc"
tmp="/tmp/bashrc"
add="export PATH=\$PATH:\$HOME/.local/bin # <DURANC>"
# remove duranc specific stuff => tmpfile
grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
# comm="sed -i '2s/^/"$add"/' "$tmp
# echo $comm
# $comm
echo $add | cat - $tmp > $fname

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
