#!/bin/bash

# Set ownership and permissions for /etc/passwd
sudo chown root:root /etc/passwd
sudo chmod 644 /etc/passwd

# Set ownership and permissions for /etc/shadow
sudo chown root:shadow /etc/shadow
sudo chmod 640 /etc/shadow

# Set ownership and permissions for /etc/group
sudo chown root:root /etc/group
sudo chmod 644 /etc/group

# Set ownership and permissions for /etc/gshadow
sudo chown root:shadow /etc/gshadow
sudo chmod 640 /etc/gshadow

# Secure home directories
for dir in /home/*; do
  sudo chmod 750 "$dir"
done

