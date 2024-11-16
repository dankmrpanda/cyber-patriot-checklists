#!/bin/bash

# Install X2GO Server
sudo add-apt-repository ppa:x2go/stable -y
sudo apt update
sudo apt install -y x2goserver x2goserver-xsession

# Allow X2GO through the firewall (uses SSH)
sudo ufw allow 22

