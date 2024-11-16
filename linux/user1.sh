#!/bin/bash

# List of authorized administrators and users
admins=("perry" "carlos" "kan" "alice" "josefina")
users=("jaimie" "adalbern" "amayas" "fabienne" "mariya" "cornelius" "harold" "taran" "felix" "angela" "rais" "miriam" "aldo" "timothy" "leilani" "viktor" "linda" "jeanne" "martin" "josef" "roger" "stacy" "suzy" "liz")

# Add authorized administrators
for admin in "${admins[@]}"; do
  if ! id -u "$admin" >/dev/null 2>&1; then
    sudo useradd -m -G sudo "$admin"
    echo "$admin:$(openssl rand -base64 14)" | sudo chpasswd
  fi
done

# Add authorized users
for user in "${users[@]}"; do
  if ! id -u "$user" >/dev/null 2>&1; then
    sudo useradd -m "$user"
    echo "$user:$(openssl rand -base64 14)" | sudo chpasswd
  fi
done

# Remove unauthorized users
current_users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
for user in $current_users; do
  if [[ ! " ${admins[@]} ${users[@]} " =~ " $user " ]]; then
    sudo userdel -r "$user"
  fi
done

# Set password aging policies
sudo sed -i 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# Enforce strong password policies
sudo apt install -y libpam-pwquality
sudo sed -i '/pam_pwquality.so/s/^#//' /etc/pam.d/common-password
sudo sed -i '/pam_pwquality.so/s/retry=3/retry=3 minlen=14 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

# Add "mariya" to "pioneers" group
sudo groupadd -f pioneers
sudo usermod -aG pioneers mariya

