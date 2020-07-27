#!/bin/bash

# Packages
sudo apt-get -y install ffmpeg python3-pip ipython3 libatlas-base-dev arp-scan libxml++2.6-dev libxslt1-dev autossh python3-numpy emacs git silversearcher-ag
    
# In order to scan more efficiently cameras, let's allow normal user to do arp scanning:    
sudo chmod u+s /usr/sbin/arp-scan
    
# For systemd daemonization to work for non-root users, do:
sudo adduser $USER systemd-journal
sudo loginctl enable-linger $USER

# for /dev/videoX access to work, must do this:
sudo addgroup $USER video

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

### complement the path to have $HOME/.local/bin
fname="/etc/sysctl.conf"
tmp="/tmp/sysctl.conf"
add1="net.core.wmem_max=2097152 # <DURANC>"
add2="net.core.rmem_max=2097152 # <DURANC>"
add3="fs.file-max = 2097152 # <DURANC>"
# remove duranc specific stuff => tmpfile
grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
# comm="sed -i '2s/^/"$add"/' "$tmp
# echo $comm
# $comm
echo $add1 >> $tmp
echo $add2 >> $tmp
echo $add3 >> $tmp
sudo cp -f $tmp $fname
sudo sysctl -p


### Increase ulimt openfiles
fname="/etc/security/limits.conf"
tmp="/tmp/limits.conf"
add1="$USER       soft    nofile          50000 # <DURANC>"
add2="$USER       hard    nofile          50000 # <DURANC>"
# remove duranc specific stuff => tmpfile
grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
# comm="sed -i '2s/^/"$add"/' "$tmp
# echo $comm
# $comm
echo $add1 >> $tmp
echo $add2 >> $tmp
sudo cp -f $tmp $fname

### Increase ulimt in user conf openfiles
fname="/etc/systemd/user.conf"
tmp="/tmp/user.conf"
add1="DefaultLimitNOFILE=50000 # <DURANC>"
# remove duranc specific stuff => tmpfile
grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
# comm="sed -i '2s/^/"$add"/' "$tmp
# echo $comm
# $comm
echo $add1 >> $tmp
sudo cp -f $tmp $fname

### Increase ulimt in user conf openfiles
fname="/etc/systemd/system.conf"
tmp="/tmp/system.conf"
add1="DefaultLimitNOFILE=50000 # <DURANC>"
# remove duranc specific stuff => tmpfile
grep -v "<DURANC>" $fname > $tmp
# add duranc specific stuff to tmpfile
# comm="sed -i '2s/^/"$add"/' "$tmp
# echo $comm
# $comm
echo $add1 >> $tmp
sudo cp -f $tmp $fname