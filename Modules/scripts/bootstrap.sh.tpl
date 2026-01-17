#!/bin/bash
apt update -y
apt upgrade -y
hostnamectl set-hostname ${hostname}

LOG="/var/log/bootstrap.log" 
echo "Bootstrapping ${role}: ${hostname}" > "$LOG" 
if [ "${role}" = "bastion-host" ]; then 
echo "Running bastion-host setup..." >> "$LOG" 
echo "Installing Ansible (via apt)..." >> "$LOG" 
apt install -y ansible-core >> "$LOG" 2>&1 
echo "Ansible installation complete." >> "$LOG" 
ansible --version >> "$LOG" 2>&1 
fi

