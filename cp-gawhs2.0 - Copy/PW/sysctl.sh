#This script will replace (And append) the /etc/sysctl.conf file

#Updating the entire "Database." Not sure why this is required, but lets do it anyways
updatedb
#Replacing /etc/sysctl.conf file
sudo chattr -i /etc/systl.conf
sudo chmod 777 /etc/sysctl.conf


#securing sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf

echo "net.ipv4.tcp_syncookies = 1"  >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 1"  >> /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 5"  >> /etc/sysctl.conf
echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.secure_redirects = 0"  >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects = 0"  >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects = 0"  >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects = 0"  >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_redirect = 0"  >> /etc/sysctl.conf
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_all =  0"  >> /etc/sysctl.conf

#securing 99-sysctl.conf
echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.d/99-sysctl.conf

#Kernel Security
echo "kernel.kptr_restrict=2" >> /etc/sysctl.d/10-kernel-hardening.conf

sysctl -ep
sudo chmod 770 /etc/sysctl.conf
