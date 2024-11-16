#!/bin/bash

# Install unattended-upgrades package
sudo apt install -y unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure --priority=low unattended-upgrades

