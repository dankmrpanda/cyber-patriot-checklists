#!/bin/bash

# Backup sysctl.conf
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak

# Apply network security settings
sudo bash -c 'cat << EOF >> /etc/sysctl.conf

# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Enable SYN cookies
net.ipv4.tcp_syncookies = 1
EOF'

# Apply changes
sudo sysctl -p

