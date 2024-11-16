#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

echo "Starting system hardening process..."

# 1. System Update and Package Management
echo "Updating system packages..."
apt update && apt full-upgrade -y
apt autoremove --purge -y
apt clean

# Install necessary security packages
echo "Installing security-related packages..."
apt install -y ufw fail2ban unattended-upgrades apt-listchanges

# 2. User and Group Management
echo "Configuring user and group settings..."

# Lock inactive user accounts
user_list=$(awk -F: '($7 !~ /nologin|false/) && ($3 >= 1000) {print $1}' /etc/passwd)
for user in $user_list; do
  last_login=$(lastlog -u "$user" | awk 'NR==2 {print $4,$5,$6}')
  if [ -z "$last_login" ]; then
    echo "Locking inactive account: $user"
    passwd -l "$user"
  fi
done

# Remove unnecessary system accounts
echo "Removing unnecessary system accounts..."
for user in games gnats irc list news uucp; do
  if id "$user" >/dev/null 2>&1; then
    userdel -r "$user"
  fi
done

# 3. Password Policies
echo "Setting password policies..."

# Enforce password complexity
apt install -y libpam-pwquality
sed -i 's/^# \(.*pam_pwquality\.so.*\)/\1/' /etc/pam.d/common-password
sed -i '/pam_pwquality\.so/ s/$/ retry=3 minlen=14 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

# Set password hashing algorithm to SHA-512
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs

# Set password aging
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# Apply password aging to existing users
for user in $(awk -F: '($3 >= 1000) {print $1}' /etc/passwd); do
  chage --maxdays 90 "$user"
  chage --mindays 7 "$user"
  chage --warndays 14 "$user"
done

# 4. File Permissions and Ownership
echo "Securing file permissions and ownership..."

# Set correct permissions for critical files
chmod 644 /etc/passwd
chmod 640 /etc/shadow
chmod 644 /etc/group
chmod 640 /etc/gshadow

chown root:root /etc/passwd
chown root:shadow /etc/shadow
chown root:root /etc/group
chown root:shadow /etc/gshadow

# Secure home directories
echo "Securing home directories..."
for dir in /home/*; do
  if [ -d "$dir" ]; then
    chmod 750 "$dir"
    chown "$(basename "$dir")":"$(basename "$dir")" "$dir"
  fi
done

# 5. Securing SSH Configuration
echo "Securing SSH configuration..."

# Backup SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F_%T)

# Configure SSH settings
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/^#*IgnoreRhosts.*/IgnoreRhosts yes/' /etc/ssh/sshd_config
sed -i 's/^#*HostbasedAuthentication.*/HostbasedAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitUserEnvironment.*/PermitUserEnvironment no/' /etc/ssh/sshd_config
sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 60/' /etc/ssh/sshd_config
sed -i 's|^#*Banner.*|Banner /etc/issue.net|' /etc/ssh/sshd_config

# Set permissions for SSH configuration
chmod 600 /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

# 6. Firewall Configuration with UFW
echo "Configuring the firewall with UFW..."

ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Enable UFW logging
ufw logging on

# Enable UFW
ufw --force enable

# 7. Disabling Unnecessary Services
echo "Disabling unnecessary services..."

services_to_disable=(
  avahi-daemon
  cups
  isc-dhcp-server
  slapd
  nfs-server
  rpcbind
  bind9
  vsftpd
  apache2
  dovecot
  smbd
  squid
  snmpd
  rsync
  nis
)

for service in "${services_to_disable[@]}"; do
  if systemctl is-enabled "$service" >/dev/null 2>&1; then
    systemctl disable "$service"
    systemctl stop "$service"
    echo "Disabled and stopped service: $service"
  fi
done

# 8. System sysctl Hardening
echo "Applying sysctl configurations..."

# Backup current sysctl.conf
cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%F_%T)

# Apply network security settings
cat <<EOF >/etc/sysctl.d/99-custom.conf
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Block SYN attacks
net.ipv4.tcp_syncookies = 1

# Log Martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Enable IPv6 (do not disable unless certain)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# Enable IP forwarding (set to 0 if not required)
net.ipv4.ip_forward = 0

# Increase the number of allowed connections
net.core.somaxconn = 1024

# Increase the maximum amount of memory buffers
net.core.optmem_max = 25165824

# Increase the TCP max buffer size
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

EOF

# Apply sysctl settings
sysctl --system

# 9. Auditing and Logging Configuration
echo "Configuring auditing and logging..."

# Install auditd
apt install -y auditd audispd-plugins

# Enable and start auditd service
systemctl enable auditd
systemctl start auditd

# Configure audit rules
cat <<EOF >/etc/audit/rules.d/audit.rules
# Monitor /etc/passwd and /etc/shadow changes
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/gshadow -p wa -k gshadow_changes

# Monitor sudoers file
-w /etc/sudoers -p wa -k sudoers_changes

# Monitor important binaries
-w /bin/ -p x -k bin_executions

# Monitor login events
-w /var/log/lastlog -p wa -k logins

# Monitor modifications to time
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
EOF

# Restart auditd to apply rules
systemctl restart auditd

# 10. Automatic Security Updates
echo "Configuring automatic security updates..."

apt install -y unattended-upgrades

cat <<EOF >/etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}:\${distro_codename}-updates";
};
Unattended-Upgrade::Automatic-Reboot "true";
EOF

dpkg-reconfigure -f noninteractive unattended-upgrades

# 11. Kernel Module Blacklisting
echo "Blacklisting unnecessary kernel modules..."

# Only blacklist modules that are confirmed to be unnecessary and not required by your system
modules_to_blacklist=(
  # Example modules that are generally safe to blacklist
  dccp
  sctp
  rds
  tipc
)

for module in "${modules_to_blacklist[@]}"; do
  echo "install $module /bin/true" >> /etc/modprobe.d/blacklist.conf
done

# 12. Configuring PAM for Additional Security
echo "Configuring PAM for additional security..."

# Enforce account lockout policy
cat <<EOF >>/etc/pam.d/common-auth

# Lock account after 5 failed login attempts
auth required pam_tally2.so deny=5 onerr=fail unlock_time=900 audit
EOF

# Enforce session timeout
echo "TMOUT=600" >> /etc/profile.d/timeout.sh
echo "readonly TMOUT" >> /etc/profile.d/timeout.sh
echo "export TMOUT" >> /etc/profile.d/timeout.sh

# 13. Secure Boot Settings
echo "Securing boot settings..."

# Avoid changing permissions on GRUB configuration to prevent boot issues
# Ensure that the GRUB configuration file is readable
chmod 644 /boot/grub/grub.cfg
chown root:root /boot/grub/grub.cfg

# 14. Set Login Warning Banners
echo "Setting login warning banners..."

cat <<EOF >/etc/issue.net
********************************************************************************
*                                  WARNING                                      *
* Unauthorized access to this system is prohibited. All activities are logged   *
* and monitored.                                                                *
********************************************************************************
EOF

cat <<EOF >/etc/issue
********************************************************************************
*                                  WARNING                                      *
* Unauthorized access to this system is prohibited. All activities are logged   *
* and monitored.                                                                *
********************************************************************************
EOF

# Update SSH to use the banner
sed -i 's|^#Banner.*|Banner /etc/issue.net|' /etc/ssh/sshd_config
systemctl restart sshd

# 15. Ensure Permissions on Cron and At
echo "Securing cron and at permissions..."

# Restrict at and cron to authorized users
chmod 600 /etc/crontab
chmod 700 /etc/cron.hourly/
chmod 700 /etc/cron.daily/
chmod 700 /etc/cron.weekly/
chmod 700 /etc/cron.monthly/
chmod 700 /etc/cron.d/

touch /etc/cron.allow
chmod 600 /etc/cron.allow
rm -f /etc/cron.deny

touch /etc/at.allow
chmod 600 /etc/at.allow
rm -f /etc/at.deny

# 16. Verify System File Integrity
echo "Installing and configuring AIDE for file integrity checking..."

# Install AIDE
apt install -y aide

# Remove existing AIDE database files to prevent prompts
rm -f /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Initialize AIDE database (this may take several minutes)
echo "Initializing AIDE database (this may take some time)..."
aide --init

# Move the new database to the working location without prompting
mv -f /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Schedule regular checks (e.g., daily via cron) if not already scheduled
if ! grep -q "aide.wrapper --check" /etc/crontab; then
  echo "0 5 * * * root /usr/bin/aide.wrapper --check" >> /etc/crontab
fi

# 17. Disable Unnecessary Filesystems
echo "Disabling unnecessary filesystems..."

# Only disable filesystems that are not in use and won't affect the system
filesystems_to_disable=(
  # These are example filesystems that are often safe to disable
  cramfs
  freevxfs
  jffs2
  hfs
  hfsplus
  squashfs
  udf
)

for fs in "${filesystems_to_disable[@]}"; do
  echo "install $fs /bin/true" >> /etc/modprobe.d/disable-$fs.conf
done

# Do not disable 'vfat' if it's needed for mounting USB drives

# 18. Final System Update and Reboot Prompt
echo "Performing final system update..."

apt update && apt upgrade -y

echo "System hardening complete. It's recommended to reboot the system."

exit 0

