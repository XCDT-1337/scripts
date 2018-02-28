#!/bin/bash
#Step I
#assumes you have a session as root
set -x
trap "echo hit return;read x" DEBUG
function randpw {
	tr -dc 'A-Za-z0-9-_!@#$%^&*()_+{}|:<>=?' < /dev/urandom | head -c 32
}

grep wikus /etc/shadow #checks for C@C supervisory user wikus
if [ $? -eq 0 ]
	then
    	deluser wikus
		delgroup wikus
		rm -rf /home/wikus
fi

apt-get update && apt-get -y upgrade #update/upgrade the system
apt-get install sudo rsync

ROOT_PASS=$(randpw)
echo "New root password: $ROOT_PASS" #set root pass
printf 'root: %s\n' "$ROOT_PASS" >> /root/script_info.txt
echo "root:$ROOT_PASS" | chpasswd

echo "Creating sudo-user eyes"
EYES_PASS=$(randpw)
printf 'eyes: %s\n' "$EYES_PASS" >> /root/script_info.txt
adduser --disable-password --gecos eyes && echo "eyes:$EYES_PASS" | chpasswd
adduser eyes sudo
#login as sudo-user
echo "Switching user"
echo $EYES_PASS | su eyes

echo "Performing ssh hardening"
cd /etc/ssh/
sudo mkdir default_deb_keys
mv ssh_host_* default_deb_keys/ #backup default ssh keys
dpkg-reconfigure openssh-server #chage keys
cd
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup #backup sshd_config
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sudo sed -i 's/Port 22/Port 7707/g' /etc/ssh/sshd_config #change ssh port to 7707 and disable sshroot
sudo systemctl restart sshd

#echo "Setting up 2-Factor Authentication"
#sudo apt-get install -y libpam0g-dev make gcc
#sudo wget http://google-authenticator.googlecode.com/files/libpam-google-authenticator-1.0-source.tar.bz2
#sudo tar -xvf libpam-google-authenticator-1.0-source.tar.bz2
#cd libpam-google-authenticator-1.0/
#sudo make && make install
#echo "you take over and write down the codes"
#google-authenticator
#echo "get those codes"
#read -rsp $'Press any key to continue...\n' -n1 keys
#sudo sed 's/# \/etc\/security\/pam_env.conf./\nauth       required     pam_google_authenticator.so' /etc/pam.d/sshd
#sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
#sudo systemctl restart sshd
IP=$(netstat -ant | grep ESTABLISHED | cut -d 1)
echo "input your local user \n"
read -rsp lusr
echo "\nis this your ip: $IP ? y/n"
read -rsp ans
if [ $ans == "y" ] then;
	echo "sending script_info.txt to your ~\n"
else if [ $ans == "n" ] then;
	echo "input your ip address\n"
	read -rsp ip
	IP=$ip
	fi
fi
echo $ROOT_PASS | sudo -i
rsync -rv /root/script_info.txt $lusr@$IP:/~
