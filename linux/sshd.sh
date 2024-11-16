#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

echo "Securing SSH Daemon based on CIS Benchmarks..."

# Step 1: Install OpenSSH Server if not installed
echo "Installing OpenSSH Server if not already installed..."
apt-get install -y openssh-server

# Step 2: Ensure sshd is enabled and running
echo "Enabling and starting sshd service..."
systemctl enable sshd
systemctl start sshd

# Step 3: Backup existing SSH configuration files
echo "Backing up SSH configuration files..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F_%T)
cp /etc/ssh/ssh_config /etc/ssh/ssh_config.bak.$(date +%F_%T)

# Step 4: Modify SSH Daemon Configuration
echo "Configuring /etc/ssh/sshd_config..."

# Define the SSH configuration parameters based on CIS Benchmarks
SSHD_CONFIG="/etc/ssh/sshd_config"

# Function to set or update configuration parameters
set_sshd_config() {
  PARAM="$1"
  VALUE="$2"
  if grep -q "^#\?\s*$PARAM" "$SSHD_CONFIG"; then
    sed -i "s|^#\?\s*$PARAM.*|$PARAM $VALUE|" "$SSHD_CONFIG"
  else
    echo "$PARAM $VALUE" >> "$SSHD_CONFIG"
  fi
}

# Disable SSH Protocol 1
set_sshd_config "Protocol" "2"

# Set LogLevel to INFO
set_sshd_config "LogLevel" "INFO"

# Disable SSH X11 Forwarding
set_sshd_config "X11Forwarding" "no"

# Set MaxAuthTries to 4 or less
set_sshd_config "MaxAuthTries" "3"

# Set IgnoreRhosts to yes
set_sshd_config "IgnoreRhosts" "yes"

# Disable Host-based Authentication
set_sshd_config "HostbasedAuthentication" "no"

# Disable PermitRootLogin
set_sshd_config "PermitRootLogin" "no"

# Disable PermitEmptyPasswords
set_sshd_config "PermitEmptyPasswords" "no"

# Disable User Environment
set_sshd_config "PermitUserEnvironment" "no"

# Use strong Ciphers and MACs
set_sshd_config "Ciphers" "aes256-ctr,aes192-ctr,aes128-ctr"
set_sshd_config "MACs" "hmac-sha2-512,hmac-sha2-256"

# Set Idle Timeout Interval for User Login
set_sshd_config "ClientAliveInterval" "300"
set_sshd_config "ClientAliveCountMax" "0"

# Limit Access to SSH
# Allow only specific users or groups (uncomment and modify as needed)
# set_sshd_config "AllowUsers" "user1 user2"
# set_sshd_config "AllowGroups" "group1 group2"

# Disable TCP Forwarding
set_sshd_config "AllowTcpForwarding" "no"

# Disable SFTP if not needed (comment out if SFTP is required)
# set_sshd_config "Subsystem sftp" "internal-sftp"

# Set Banner (Uncomment and modify the path if you have a custom banner)
# set_sshd_config "Banner" "/etc/issue.net"

# Step 5: Modify SSH Client Configuration
echo "Configuring /etc/ssh/ssh_config..."

SSH_CONFIG="/etc/ssh/ssh_config"

# Ensure SSH client does not send environment variables
sed -i 's/^#\?   SendEnv.*/    SendEnv LANG LC_*/' "$SSH_CONFIG"

# Step 6: Adjust File Permissions and Ownership
echo "Adjusting file permissions and ownership..."

# Set permissions for sshd_config
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config

# Set permissions for ssh_config
chown root:root /etc/ssh/ssh_config
chmod 644 /etc/ssh/ssh_config

# Set permissions for SSH host keys
echo "Setting permissions for SSH host keys..."
for key in /etc/ssh/ssh_host_*_key; do
  chown root:root "$key"
  chmod 600 "$key"
done

for pubkey in /etc/ssh/ssh_host_*_key.pub; do
  chown root:root "$pubkey"
  chmod 644 "$pubkey"
done

# Step 7: Restart SSH Service
echo "Restarting sshd service to apply changes..."
systemctl restart sshd

echo "SSH Daemon has been secured based on CIS Benchmarks."

# Step 8: Optional - Display SSHD Configuration for Verification
echo "Would you like to view the updated /etc/ssh/sshd_config? (y/n)"
read -r VIEW_CONFIG
if [ "$VIEW_CONFIG" = "y" ] || [ "$VIEW_CONFIG" = "Y" ]; then
  less /etc/ssh/sshd_config
fi

exit 0

