#!/bin/bash

# Packages
sudo apt-get -y install python3-pip ipython3 python3-numpy python3-opencv redis-server qt5-default swig

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

# create a directory for systemd logs that does not disappear between boots
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal

### add line "Storage=persistent" to "/etc/systemd/journald.conf"
fname="/etc/systemd/journald.conf"
tmp="/tmp/journald.conf.tmp"
# lines to be added
add1="Storage=persistent # <DURANC>"
add2="RateLimitInterval=0 # <DURANC>"
add3="RateLimitBurst=0 # <DURANC>"
add4="SystemMaxUse=100M # <DURANC>"
# remove duranc specific stuff => tmpfile
sudo grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
sudo echo $add1 >> $tmp
sudo echo $add2 >> $tmp
sudo echo $add3 >> $tmp
sudo echo $add4 >> $tmp
# tmpfile to final file
sudo cp -f $tmp $fname

# *** restart to make the changes effective ***
sudo systemctl restart systemd-journald

