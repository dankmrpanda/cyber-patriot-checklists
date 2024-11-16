#!/bin/bash

# Install auditd
sudo apt install -y auditd audispd-plugins

# Enable auditd service
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure audit rules
sudo bash -c 'cat << EOF > /etc/audit/rules.d/audit.rules
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/gshadow -p wa -k gshadow_changes
-w /var/log/ -p wa -k log_changes
EOF'

# Restart auditd
sudo systemctl restart auditd

