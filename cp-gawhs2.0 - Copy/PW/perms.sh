chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow

chown root:root /etc/hosts.deny
chmod 644 /etc/hosts.deny

chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

chown root:root /etc/passwd
chmod 644 /etc/passwd
chown root:root /etc/passwd-
chmod 600 /etc/passwd-
chown root:shadow /etc/gshadow-
chmod 640 /etc/gshadow-
chown root:shadow /etc/shadow
chmod 640 /etc/shadow
chown root:shadow /etc/shadow-
chmod 640 /etc/shadow-
chown root:root /etc/group
chmod 644 /etc/group
chown root:root /etc/group-
chmod 644 /etc/group-
