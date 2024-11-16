#!/bin/bash

# Enable UFW
sudo ufw --force enable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (port 22)
sudo ufw allow OpenSSH

# Allow X2GO server (port 22)
sudo ufw allow 22

# Allow other necessary services (if any)

# Deny all other ports explicitly (optional)
# sudo ufw deny 1:65535/tcp
# sudo ufw deny 1:65535/udp

# Reload UFW
sudo ufw reload

