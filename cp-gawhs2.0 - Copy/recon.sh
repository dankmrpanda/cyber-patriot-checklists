#!/usr/bin/env bash

sudo su

mkdir Recon
cd Recon

#makes Main directory
mkdir Main

#Shell
mkdir Shell 
cd Shell 
touch authlog.txt && cat /var/log/auth.log > authlog.txt 
touch installhistory1.txt && cat /var/log/dpkg.log > installhistory1.txt
touch installhistory2.txt && cat /var/log/dpkg.log.1 > installhistory2.txt
touch aliases.txt && alias > aliases.txt 
touch sources.list.txt && apt-cache policy > sources.list.txt && echo " " >> sources.list.txt && cat /etc/apt/sources.list >> sources.list.txt && echo " " >> sources.list.txt && ls -la /etc/apt/sources.list* >> sources.list.txt
touch sudo.txt && dpkg -s sudo > sudo.txt && echo " " >> sudo.txt && cat /etc/sudoers >> sudo.txt
touch issue.txt && cat /etc/issue > issue.txt
touch issue.net.txt && cat /etc/issue.net > issue.net.txt
touch gmd.txt && cat /etc/gdm3/greeter.dconf-defaults > gdm.txt
touch pwquality.txt && cat /etc/pwquality.conf > pwquality.txt
cat /var/log/* > logs.txt
cat /var/log/apt/* >> logs.txt
cat /
cd ..
cp Shell/installhistory* Main 
cp Shell/a* Main
cp Shell/sudo* Main


#Box Items 
mkdir Items 
sudo apt install net-tools 
touch osversion.txt && cat /etc/os-release >> osversion.txt && echo " " >> osversion.txt && lsb_release -a >> osversion.txt && echo " " >> osversion.txt && hostnamectl >> osversion.txt 
sudo dpkg --list > installeditems.txt
sudo netstat -peanut > "netstat-p.txt"
echo "" >> "netstat-p.txt"
echo "ifconfig:" >> "netstat-p.txt"
ifconfig >> "netstat-p.txt"
echo "" >> "netstat-p.txt"
echo "nmcli:" >> "netstat-p.txt"
nmcli >> "netstat-p.txt"
nmcli g >> "netstat-p.txt"
nmcli d >> "netstat-p.txt"
mcli device show >> "netstat-p.txt"
nmcli device show >> "netstat-p.txt"
touch motd.txt && cat /run/motd.dynamic > motd.txt && echo " " >> motd.txt && sudo run-parts -v /etc/update-motd.d/ > motd.txt 
touch homedir.txt && ls -la /home/*/* > homedir.txt 
alsaucm listcards > cards.txt

# touch perms.txt &&  df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002 > perms.txt
# touch perms.txt && find <partition> -xdev -type f -perm -0002 > perms.txt && echo " " >> perms.txt && find <partition> -xdev -nouser perms.txt && echo " " >> perms.txt && find <partition> -xdev -nogroup >> perms.txt

#Files
mkdir Files 
cd Files
touch "No no files" 
find / -iname '*.mp3' -type f > "No no files"
find / -iname '*.mov' -type f >> "No no files"
find / -iname '*.mp4' -type f >> "No no files"
find / -iname '*.avi' -type f >> "No no files"
find / -iname '*.mpg' -type f >> "No no files"
find / -iname '*.mpeg' -type f >> "No no files"
find / -iname '*.flac' -type f >> "No no files"
find / -iname '*.m4a' -type f >> "No no files"
find / -iname '*.flv' -type f >> "No no files"
find / -iname '*.ogg' -type f >> "No no files"
find / -iname '*.mov' -type f >> "No no files"
find / -iname '*.txt' -type f >> "No no files"
find / -iname '*.txt' -type f >> "No no files"
find /home -iname '*.gif' -type f >> "No no files"
find /home -iname '*.png' -type f >> "No no files"
find /home -iname '*.jpg' -type f >> "No no files"
find /home -iname '*.jpeg' -type f >> "No no files"

touch perms
getfacl -Rs /home /etc /var | less >> perms
lsattr -R /etc 2>/dev/null | grep -v -e '--e--' | grep -v -e '/.*:$' | grep -v '^$' >> perms
lsattr -R /home 2>/dev/null | grep -v -e '--e--' | grep -v -e '/.*:$' | grep -v '^$' >> perms
lsattr -R /root 2>/dev/null | grep -v -e '--e--' | grep -v -e '/.*:$' | grep -v '^$' >> perms
lsattr -R /var 2>/dev/null | grep -v -e '--e--' | grep -v -e '/.*:$' | grep -v '^$' >> perms
find / -type f -perm -4000 >> perms
cd ..

mv osversion.txt Items && mv installeditems.txt Items && mv "netstat-p.txt" Items && mv motd.txt Items && mv homedir.txt Items
cp /Items/"No no files" Main

#Users and Passwords 
mkdir Users 
touch finalusers.txt && touch passwd.txt && sudo awk -F ":" '{print $1}'  /etc/passwd > passwd.txt | sort -nk1 passwd.txt && sort -nk1 user.txt | diff -y user.txt passwd.txt > finalusers.txt
touch auth.txt && sudo awk -F ":" '{print $1}' /etc/shadow > auth.txt && echo " " >> auth.txt && sudo awk -F ":" '{print $2}' /etc/shadow >> auth.txt
touch admin.txt && touch groups.txt && cat /etc/group > groups.txt && grep "adm" /etc/group > admin.txt && grep "sudo" /etc/group >> admin.txt  
sudo cat /etc/passwd > passwd.txt 
touch shadow.txt && sudo cat /etc/shadow > shadow.txt 
touch passwdcmp.txt && cat /etc/pam.d/common-password > passwdcmp.txt 
touch logindefs.txt && cat /etc/login.defs > logindefs.txt
touch full.txt && awk -F ":" '{ printf $3 ":" $1; system("groups " $1 "| cut -d \":\" -f2 | sed \"s/^ */:/g\" | sed \"s/ /,/g\"") }' /etc/passwd > full.txt 
ls -o /etc/passwd > perms.txt 
ls -o /etc/shadow >> perms.txt
cp auth.txt Main && cp admin.txt Main && cp perms.txt Main 
mv finalusers.txt Users && mv admin.txt Users && mv groups.txt Users && mv auth.txt Users && mv passwd.txt Users && mv shadow.txt Users && mv passwdcmp.txt Users && mv logindefs.txt Users && mv full.txt Users && mv perms.txt Users 

#Cron Processes 
mkdir Cron 
touch crontab.txt && echo "crontab:" >> crontab.txt && crontab -l > crontab.txt 
echo " " >> crontab.txt && echo "Hourly:" >> crontab.txt && ls -la /etc/cron.hourly/ >> crontab.txt 
echo " " >> crontab.txt && echo "Daily:" >> crontab.txt && ls -la /etc/cron.daily/ >> crontab.txt 
echo " " >> crontab.txt && echo "Weekly:" >> crontab.txt && ls -la /etc/cron.weekly/ >> crontab.txt 
echo " " >> crontab.txt && echo "Monthly:" >> crontab.txt && ls -la /etc/cron.monthly/ >> crontab.txt 
touch cronroot.txt && sudo crontab -u root -l > cronroot.txt && echo " " >> cronroot.txt && cat /etc/crontab >> cronroot.txt 
cp crontab.txt Main 
mv crontab.txt Cron && mv cronroot.txt Cron

#Kernel
mkdir "System Info" 
touch logs.txt && journalctl > logs.txt 
touch version.txt && uname -a > version.txt 
touch boot.txt && systemd-analyze blame > boot.txt 
mv logs.txt Kernel && mv version.txt Kernel && mv boot.txt Kernel 

#Services 
mkdir Services 
touch services.txt && cat /etc/services > services.txt
sudo service --status-all > servicestatus.txt 
sudo netstat -tulpn > "netstat-t.txt"
ls -al ~/.ssh
touch keys.txt && cat id_rsa.pub > keys.txt && echo " " keys.txt && echo " " keys.txt && cat id_ecdsa.pub >> keys.txt && echo " " keys.txt && echo " " keys.txt && cat id_ed25519.pub >> keys.txt 
mv "netstat-t.txt" Services && mv servicestatus.txt Services && mv keys.txt Services mv services.txt Services

#Firewall
mkdir Firewall 
touch version.txt && ufw version > version.txt 
touch rules.txt && sudo ufw status numbered > rules.txt && echo " " >>  rules.txt && sudo ufw status verbose >> rules.txt 
touch log.txt && cat /var/log/ufw.log > log.txt 
touch iptables.txt && iptables -L > iptables.txt 
mv version.txt Firewall && mv log.txt Firewall && mv iptables.txt Firewall && mv rules.txt Firewall 

#Important Configs 
mkdir Configs
cd Configs
mkdir sysctl
cd sysctl 
touch sysctl.txt && cat /etc/sysctl.conf > sysctl.txt 
cd ..
mkdir SSH
cd SSH
touch ssh.txt && cat /etc/ssh/ssh_config > ssh.txt 
touch sshd.txt && cat /etc/ssh/sshd_config > sshd.txt 
cd ..
mkdir Samba 
cd Samba 
touch smbconf.txt && cat /etc/samba/smb.conf > smbconf.txt 
cd ..
mkdir DNS 
cd DNS 
touch resolv.txt && cat /etc/resolv.conf > resolv.txt 
touch hosts.txt && echo "Hosts:" > hosts.txt && cat /etc/hosts >> hosts.txt && echo " " >> hosts.txt && echo "Hostname:" >> hosts.txt && cat /etc/hostname >> hosts.txt  && echo " " >> hosts.txt && echo " host.conf:" >> hosts.txt && cat /etc/host.conf >> hosts.txt && echo " " >> hosts.txt  && echo "hosts.allow:" >> hosts.txt && cat /etc/hosts.allow >> hosts.txt && echo " " >> hosts.txt && echo "hosts.deny:" >> hosts.txt && cat /etc/hosts.deny >> hosts.txt 
cd ..
mkdir FTP
cd FTP 
touch vsftpd_conf.txt && cat /etc/vsftp.conf > vsftpd_conf.txt
touch proftpd_conf.txt && cat /etc/proftpd/proftpd.conf > proftpd_conf.txt
touch pureftpd_conf.txt && cat /etc/pure-ftpd.conf > pureftpd_conf.txt
cd ..
mkdir Apache
cd Apache 
touch apacheconf.txt && cat /etc/apache*/*/* > apacheconf.txt 

cd ..
mkdir SQL
cd SQL
touch postgresqlconf.txt && cat /etc/postgresql/9.5/main/postgresql.conf > postgresqlconf.txt 
cd ..
mkdir nginx
cd nginx
touch nginx.txt 
cat /etc/nginx/* > nginx.txt 
cd ..
cd ..
cp /Configs/sysctl/* Main
