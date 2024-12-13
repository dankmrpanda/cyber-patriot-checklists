#!/bin/bash

# Auditd Configuration Script for Mint 21
# Based on the latest CIS Benchmarks

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with administrative privileges (sudo)."
    exit 1
fi

echo "Starting Auditd configuration..."

# Install Auditd and associated plugins
echo "Installing Auditd..."
apt update
apt -y install auditd audispd-plugins

# Enable and start Auditd service
echo "Enabling and starting Auditd service..."
systemctl enable auditd
systemctl start auditd

# Backup existing Auditd configuration
echo "Backing up existing Auditd configuration..."
AUDITD_CONF="/etc/audit/auditd.conf"
cp "$AUDITD_CONF" "${AUDITD_CONF}.bak_$(date +%F_%T)"

# Configure Auditd settings according to CIS Benchmarks
echo "Configuring Auditd settings..."
sed -i 's/^max_log_file = .*/max_log_file = 50/' "$AUDITD_CONF"
sed -i 's/^#max_log_file_action = .*/max_log_file_action = keep_logs/' "$AUDITD_CONF"
sed -i 's/^space_left_action = .*/space_left_action = email/' "$AUDITD_CONF"
sed -i 's/^action_mail_acct = .*/action_mail_acct = root/' "$AUDITD_CONF"
sed -i 's/^admin_space_left_action = .*/admin_space_left_action = halt/' "$AUDITD_CONF"
sed -i 's/^disk_full_action = .*/disk_full_action = halt/' "$AUDITD_CONF"
sed -i 's/^disk_error_action = .*/disk_error_action = halt/' "$AUDITD_CONF"

# Configure Audisp to send syslog events
echo "Configuring Audisp to send syslog events..."
AUDISP_CONF="/etc/audisp/plugins.d/au-remote.conf"
sed -i 's/^active = .*/active = yes/' "$AUDISP_CONF"

# Configure Audit rules according to CIS Benchmarks
echo "Configuring Audit rules..."
AUDIT_RULES="/etc/audit/rules.d/cis_audit.rules"

# Create the audit rules file
cat <<EOL > "$AUDIT_RULES"
## Audit Rules per CIS Benchmarks

# Record Events That Modify Date and Time Information
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change

# Record Events That Modify User/Group Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Record Events That Modify Network Environment
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network -p wa -k system-locale

# Record Events That Modify the System's Mandatory Access Controls
-w /etc/selinux/ -p wa -k MAC-policy

# Collect Login and Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Collect Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Monitor Privileged Commands
EOL

# Find all setuid and setgid files and add them to the audit rules
echo "Adding setuid and setgid files to audit rules..."
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | while read -r FILE; do
    echo "-a always,exit -F path=$FILE -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" >> "$AUDIT_RULES"
done

# Ensure changes to system administration scope (sudoers) is collected
echo "-w /etc/sudoers -p wa -k scope" >> "$AUDIT_RULES"
echo "-w /etc/sudoers.d/ -p wa -k scope" >> "$AUDIT_RULES"

# Ensure system administrator actions (sudolog) are collected
echo "-w /var/log/sudo.log -p wa -k actions" >> "$AUDIT_RULES"

# Collect kernel module loading and unloading
echo "-w /sbin/insmod -p x -k modules" >> "$AUDIT_RULES"
echo "-w /sbin/rmmod -p x -k modules" >> "$AUDIT_RULES"
echo "-w /sbin/modprobe -p x -k modules" >> "$AUDIT_RULES"
echo "-a always,exit -F arch=b64 -S init_module,delete_module -k modules" >> "$AUDIT_RULES"

# Restart Auditd to apply changes
echo "Restarting Auditd service..."
augenrules --load
systemctl restart auditd

# Verify Auditd status
echo "Verifying Auditd status..."
systemctl is-active --quiet auditd
if [ $? -eq 0 ]; then
    echo "Auditd is running."
else
    echo "Auditd is not running. Please check the service status."
fi

echo "Auditd configuration completed according to CIS Benchmarks."
