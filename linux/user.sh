#!/bin/bash

# List of authorized users and administrators
declare -A AUTH_USERS
declare -A AUTH_ADMINS

# Populate AUTH_USERS and AUTH_ADMINS
AUTH_ADMINS=(
    ["perry"]="M4mm@lOfAct!0n"
    ["carlos"]="M4mm@lOfAct!0n"
    ["kan"]="M4mm@lOfAct!0n"
    ["alice"]="M4mm@lOfAct!0n"
    ["josefina"]="M4mm@lOfAct!0n"
)

AUTH_USERS=(
    ["jaimie"]="M4mm@lOfAct!0n"
    ["adalbern"]="M4mm@lOfAct!0n"
    ["amayas"]="M4mm@lOfAct!0n"
    ["fabienne"]="M4mm@lOfAct!0n"
    ["mariya"]="M4mm@lOfAct!0n"
    ["cornelius"]="M4mm@lOfAct!0n"
    ["harold"]="M4mm@lOfAct!0n"
    ["taran"]="M4mm@lOfAct!0n"
    ["felix"]="M4mm@lOfAct!0n"
    ["angela"]="M4mm@lOfAct!0n"
    ["rais"]="M4mm@lOfAct!0n"
    ["miriam"]="M4mm@lOfAct!0n"
    ["aldo"]="M4mm@lOfAct!0n"
    ["timothy"]="M4mm@lOfAct!0n"
    ["leilani"]="M4mm@lOfAct!0n"
    ["viktor"]="M4mm@lOfAct!0n"
    ["linda"]="M4mm@lOfAct!0n"
    ["jeanne"]="M4mm@lOfAct!0n"
    ["martin"]="M4mm@lOfAct!0n"
    ["josef"]="M4mm@lOfAct!0n"
    ["roger"]="M4mm@lOfAct!0n"
    ["stacy"]="M4mm@lOfAct!0n"
    ["suzy"]="M4mm@lOfAct!0n"
    ["liz"]="M4mm@lOfAct!0n"
)

# Convert keys of AUTH_USERS and AUTH_ADMINS into arrays
AUTHORIZED_USERS=(${!AUTH_USERS[@]})
AUTHORIZED_ADMINS=(${!AUTH_ADMINS[@]})

# Ensure the perry user and the nobody user remain unaffected
EXEMPT_USERS=("perry" "nobody")

# Remove unauthorized human users but keep their files
for user in $(cut -d: -f1 /etc/passwd); do
    USER_UID=$(id -u "$user" 2>/dev/null)
    if [[ "$USER_UID" -ge 1000 && ! " ${EXEMPT_USERS[@]} " =~ " $user " && ! ${AUTH_USERS[$user]+_} && ! ${AUTH_ADMINS[$user]+_} ]]; then
        echo "Removing unauthorized human user: $user"
        sudo userdel "$user"
    fi
done

# Set passwords and adjust admin privileges
for user in "${AUTHORIZED_USERS[@]}" "${AUTHORIZED_ADMINS[@]}"; do
    if id "$user" &>/dev/null; then
        # Set password
        echo "${AUTH_USERS[$user]:-M4mm@lOfAct!0n}" | sudo passwd --stdin "$user" &>/dev/null
        
        if [[ " ${AUTHORIZED_ADMINS[@]} " =~ " $user " ]]; then
            # Add to sudoers if an admin
            sudo usermod -aG sudo "$user"
            echo "User $user is granted admin privileges."
        else
            # Remove sudo privileges if not an admin
            sudo deluser "$user" sudo
            echo "User $user is granted standard user privileges."
        fi
    else
        echo "Creating user: $user"
        sudo useradd -m "$user"
        echo "${AUTH_USERS[$user]:-M4mm@lOfAct!0n}" | sudo passwd --stdin "$user" &>/dev/null
        if [[ " ${AUTHORIZED_ADMINS[@]} " =~ " $user " ]]; then
            sudo usermod -aG sudo "$user"
            echo "User $user is granted admin privileges."
        fi
    fi
done

echo "System security setup complete."

