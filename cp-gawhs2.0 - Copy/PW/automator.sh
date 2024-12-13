#Automates all the scripts in the directory
#Needs to be updated
sudo apt-get -y install libpam-pwquality
sudo ./lightdm.sh
sudo ./rootpwchange.sh
sudo cat login.defs.mod > /etc/login.defs
sudo cat sysctl.conf.old > /etc/sysctl.conf

