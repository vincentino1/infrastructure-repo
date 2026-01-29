#!/bin/bash
apt update -y
apt upgrade -y
hostnamectl set-hostname ${hostname}

LOG="/var/log/bootstrap.log" 
echo "Bootstrapping ${role}: ${hostname}" > "$LOG" 

if [ "${role}" = "bastion-host" ]; then 
echo "Running bastion-host setup..." >> "$LOG" 

echo "Installing Ansible (via pip)..." >> "$LOG" 
apt install -y python3-pip >> "$LOG" 2>&1

python3 -m pip install --user --upgrade ansible >> "$LOG" 2>&1
echo "Ansible installation complete." >> "$LOG"

export PATH=$HOME/.local/bin:$PATH
 
echo "Ansible installation complete." >> "$LOG" 
ansible --version >> "$LOG" 2>&1 
fi

 