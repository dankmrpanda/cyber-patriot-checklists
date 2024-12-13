sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw default deny routed
sudo ufw allow in on lo
sudo ufw deny in from 127.0.0.0/8
sudo ufw deny in from ::1
# ufw allow out to any port [Service port]
# Ex.(ssh)
# ufw allow out to any port 22 
