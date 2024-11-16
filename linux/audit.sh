#!/bin/bash

# Find unowned files
sudo find / -nouser -o -nogroup -exec rm -f {} \;

# Find world-writable files
sudo find / -xdev -type f -perm -0002 -exec chmod o-w {} \;

# Find SUID and SGID files
sudo find / -xdev \( -perm -4000 -o -perm -2000 \) -type f > suid_sgid_files.txt

