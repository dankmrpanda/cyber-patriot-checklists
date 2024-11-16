#!/bin/bash

# Update package list and upgrade installed packages
sudo apt update && sudo apt full-upgrade -y

# Remove unnecessary packages
sudo apt autoremove --purge -y

# Install necessary packages
sudo apt install -y ufw firefox thunderbird perl

# Ensure Firefox is installed from the official Mozilla PPA
sudo add-apt-repository ppa:mozillateam/ppa -y
sudo apt update
sudo apt install -y firefox

# Remove Firefox SNAP package if installed
sudo snap remove firefox

# Clean up
sudo apt clean

