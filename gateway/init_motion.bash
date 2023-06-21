#!/bin/bash
date=`date`

# Packages
echo "Updating OS Packages..."
sudo apt-get update 2> $HOME/update_error.txt

# Check if apt-get command is successfull or not
if [ -s $HOME/update_error.txt ]; then
	# The file is not-empty.
	echo -e "\e[31mapt-get update command is NOT successfull...Please check\e[0m"
	# check if apt-get update has error
	FILE_UPDATE_TO_CHECK="$HOME/update_error.txt"
	STRING_UPDATE_TO_CHECK="E:"
	if grep -q "$STRING_UPDATE_TO_CHECK" "$FILE_UPDATE_TO_CHECK"
	then
		echo " "
		echo "***Warning: There are errors while running apt-update... Please resolve them***"
		echo "***Warning: There are errors while running apt-update at $date... Please resolve them***" > $HOME/gw_update_error.txt
		echo " "
	fi
	exit
else
	# The file is empty.
	echo "apt-get update is successfull...Continue to next step"
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ffmpeg python3-pip ipython3 libatlas-base-dev arp-scan libxml++2.6-dev libxslt1-dev autossh python3-numpy emacs git silversearcher-ag motion libgeos-dev python3-skimage python3-opencv python3-matplotlib unzip

	# Install VLC player
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y vlc
fi

# In order to scan more efficiently cameras, let's allow normal user to do arp scanning:    
sudo chmod u+s /usr/sbin/arp-scan
    
# For systemd daemonization to work for non-root users, do:
sudo adduser $USER systemd-journal
sudo loginctl enable-linger $USER

# for /dev/videoX access to work, must do this:
sudo addgroup $USER video

# Upgrade PIP
pip3 install --upgrade pip

# check for sudo permission duplicate entry in sudoers file
FILE_TO_CHECK_1="/etc/sudoers"
STRING_TO_CHECK_1="$USER ALL=(ALL) NOPASSWD:ALL"
if  sudo grep -q "$STRING_TO_CHECK_1" "$FILE_TO_CHECK_1" ; then
	echo 'sudo permission entry exists in sudoers file' ;
else
	## Add Sudo permision to gwuser
	echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers >/dev/null
fi

# installation new mp4 recovery software [untrunc]
FILEDIRECTORY_UNTRUNC=$HOME/.recovery/untrunc-new
UNTRUNC_FILE=untrunc

if [ ! -e $FILEDIRECTORY_UNTRUNC/$UNTRUNC_FILE ]
then
	DIRECTORY="$HOME/.recovery"
	if [ -d "$DIRECTORY" ]; then
		# Remove recovery directory
		rm -fR $DIRECTORY/untrunc-new
	fi
	
	# Recovery of broken mp4 clips
	mkdir -p $HOME/.recovery/untrunc-new
	echo 'Recovery directory created:' $DIRECTORY

	# install packaged dependencies
	sudo apt-get update
	sudo apt-get install -y libavformat-dev libavcodec-dev libavutil-dev
	
	# get the source code
	cd $HOME/.recovery/untrunc-new
	git clone https://github.com/anthwlock/untrunc.git .
	
	# compile untrunc
	cd $HOME/.recovery/untrunc-new/
	make
	sudo cp $HOME/.recovery/untrunc-new/untrunc /usr/local/bin 
else
    echo 'New Untrunc Already Compiled....'
fi

# Install Motion software
mkdir -p $HOME/.motion
mkdir -p $HOME/.motion/feeds
mkdir -p $HOME/.motion/event

# Check hardware version for Raspberry Pi
hdver=`uname -m`
if [ $hdver != "armv7l" ] 
then
	echo "This is regular machine..."
	# Perform below steps only if internet is working
	ping -q -c3 "www.google.com" > /dev/null
	if [ $? -eq 0 ]
	then
		echo "Internet UP"
		mv $HOME/.motion/motion.conf $HOME/.motion/motion-orig.conf
		#wget -O $HOME/.motion/motion.conf https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/motion-latest.conf
		motion_version=`/usr/bin/dpkg -s motion | grep Version`
		echo "motion-version: " $motion_version
		if [[ "$motion_version" == *"4.0"* ]]
		then
			wget -O $HOME/.motion/motion.conf https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/motion.conf
		else
			wget -O $HOME/.motion/motion.conf https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/motion-latest.conf
		fi

		# CHECK IF MOTION.CONF FILE IS EMPTY OR NOT
		if [ -s $HOME/.motion/motion.conf ]; then
			# The file is not-empty.
			echo -e "\e[31mMotion configuration downloaded successfully\e[0m"
			rm -f $HOME/.motion/motion-orig.conf
		else
			# The file is empty.
			mv $HOME/.motion/motion-orig.conf $HOME/.motion/motion.conf
		fi

		##SCRIPT FOR DOWNLOADING LATEST WEIGHT FILES --START ->
		# Input file
		FILEDIRECTORY=$HOME/.motion/weights
		FILE1=latestweight.txt
		FILE2=currentweight.txt

		if [ -e $FILEDIRECTORY/$FILE1 ]
		then
			echo "File Exists"
			rm -f $FILEDIRECTORY/$FILE1
			wget -O $HOME/.motion/weights/latestweight.txt https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/latestweight.txt
			diff --brief <(sort $FILEDIRECTORY/$FILE1) <(sort $FILEDIRECTORY/$FILE2) >/dev/null
			comp_value=$?
			#Comparing two files
			if [ $comp_value -eq 1 ]
			then
				echo "Files are different - Performing Weight Files Update"
				wget -O $HOME/.motion/weights/libdarknet.so https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/libdarknet.so
				wget -O $HOME/.motion/weights/duranc_tiny_v3.weights https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.weights
				wget -O $HOME/.motion/weights/duranc_tiny_v3.names https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.names
				wget -O $HOME/.motion/weights/duranc_tiny_v3.cfg https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.cfg
				# Copy latestweight.txt TO currentweight.txt
				cp $FILEDIRECTORY/$FILE1 $FILEDIRECTORY/$FILE2
			else
				echo "No change in Files"
			fi
		else
			# Fresh Installation, create weights file directory
			mkdir -p $HOME/.motion/weights
			echo "You need to download $FILE1"
			wget -O $HOME/.motion/weights/latestweight.txt https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/latestweight.txt
			wget -O $HOME/.motion/weights/libdarknet.so https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/libdarknet.so
			wget -O $HOME/.motion/weights/duranc_tiny_v3.weights https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.weights
			wget -O $HOME/.motion/weights/duranc_tiny_v3.names https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.names
			wget -O $HOME/.motion/weights/duranc_tiny_v3.cfg https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/weights/duranc_tiny_v3.cfg
			# Copy latestweight.txt TO currentweight.txt
			cp $FILEDIRECTORY/$FILE1 $FILEDIRECTORY/$FILE2
		fi
		##SCRIPT FOR DOWNLOADING LATEST WEIGHT FILES --END <-
	else
		echo "Internet Down"
	fi
else
	echo "This is Raspberry Pi..."
	# Perform below steps only if internet is working
	ping -q -c3 "www.google.com" > /dev/null
	if [ $? -eq 0 ]
	then
		echo "Internet UP"
		mv $HOME/.motion/motion.conf $HOME/.motion/motion-orig.conf
		wget -O $HOME/.motion/motion.conf https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/motion_pi.conf
		# CHECK IF MOTION.CONF FILE IS EMPTY OR NOT
		if [ -s $HOME/.motion/motion.conf ]; then
			# The file is not-empty.
			echo -e "\e[31mMotion configuration downloaded successfully\e[0m"
			rm -f $HOME/.motion/motion-orig.conf
		else
			# The file is empty.
			mv $HOME/.motion/motion-orig.conf $HOME/.motion/motion.conf
		fi
	else
		echo "Internet Down"
	fi
fi

# check for motion.conf duplicate entry in root cron tab
FILE_TO_CHECK="/var/spool/cron/crontabs/root"
STRING_TO_CHECK="motion.conf"
if  sudo grep -q "$STRING_TO_CHECK" "$FILE_TO_CHECK" ; then
	echo 'motion conf entry exists in cron tab' ;
else
	echo "@reboot /usr/bin/motion -c $HOME/.motion/motion.conf" | sudo tee -a /var/spool/cron/crontabs/root >/dev/null 	## Add cronjob of motion

fi

# Installing PM2 for NodeJS Streamer
FILEDIRECTORY_LOCALSTR=$HOME/.localstr
LOCALSTR_FILE=index.js
NOD_MOD=$HOME/.localstr/node_modules

#if [ ! -e $FILEDIRECTORY_LOCALSTR/$LOCALSTR_FILE ]
if [ ! -d "$NOD_MOD" ]
then
	# Local Streamer Installation
	sudo apt update
	sudo apt install curl -y
	#sudo apt autoremove -y
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
#local rtsp server install/update
wget -O - https://github.com/DurancOy/duranc_bootstrap/raw/master/gateway/mediamtx/mediamtx_update.bash|bash
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

