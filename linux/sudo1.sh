#!/bin/bash

# Ensure sudo requires TTY
sudo sed -i 's/^Defaults\s\+!requiretty/Defaults requiretty/' /etc/sudoers

# Log sudo commands
sudo sed -i 's/^Defaults\s\+env_reset/&\nDefaults logfile="\/var\/log\/sudo.log"/' /etc/sudoers

