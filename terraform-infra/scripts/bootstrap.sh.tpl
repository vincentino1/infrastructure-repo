#!/bin/bash
apt update -y
apt upgrade -y
hostnamectl set-hostname ${hostname}

LOG="/var/log/bootstrap.log" 
echo "Bootstrapping ${role}: ${hostname}" > "$LOG" 

############################################
# JENKINS SERVER SETUP
############################################
if [ "${role}" = "jenkins-server" ]; then
    echo "Running jenkins-server setup..." >> "$LOG"

    echo "Installing Python3 + pip for Jenkins..." >> "$LOG"
    apt install -y python3 python3-pip >> "$LOG" 2>&1

    echo "Verifying Python installation..." >> "$LOG"
    python3 --version >> "$LOG" 2>&1
    pip3 --version >> "$LOG" 2>&1
fi

############################################
# BASTION HOST SETUP
############################################

if [ "${role}" = "bastion-host" ]; then 
echo "Running bastion-host setup..." >> "$LOG" 

echo "Installing Ansible (via pip)..." >> "$LOG" 
apt install -y python3-pip >> "$LOG" 2>&1

pip3 install ansible >> "$LOG" 2>&1

export PATH=/usr/local/bin:$PATH

echo "Ansible installation complete." >> "$LOG"
which ansible >> "$LOG" 2>&1
ansible --version >> "$LOG" 2>&1
ansible --version >> "$LOG" 2>&1 


# this ensures we have the correct version of the community.general collection, 
# which is required for some of our playbooks. 
# The version that comes with ansible-core 2.15 is too old and causes errors. 
# We need at least 12.3.0, which is compatible with ansible-core 2.15.

echo "Fixing community.general collection version..." >> "$LOG"

# Remove any old versions
rm -rf ~/.ansible/collections/ansible_collections/community/general >> "$LOG" 2>&1

# Install exactly 12.3.0
ansible-galaxy collection install community.general:12.3.0 --force >> "$LOG" 2>&1

# Verify
ansible-galaxy collection list | grep community.general >> "$LOG" 2>&1

fi

 