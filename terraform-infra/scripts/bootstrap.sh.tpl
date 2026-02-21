#!/bin/bash
apt update -y
apt upgrade -y
hostnamectl set-hostname ${hostname}

LOG="/var/log/bootstrap.log" 
echo "Bootstrapping ${role}: ${hostname}" > "$LOG" 


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

fi

 