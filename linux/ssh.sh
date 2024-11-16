#!/bin/bash

# Install OpenSSH Server if not installed
sudo apt install -y openssh-server

# Backup SSH configuration
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Secure SSH settings
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/#LoginGraceTime.*/LoginGraceTime 60/' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart sshd

