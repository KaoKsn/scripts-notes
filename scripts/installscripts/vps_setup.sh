#!/usr/bin/bash

########### Confirmation ###############
echo -e "Usage: $0 username hostname\n"
read -p "Continue? [y/N]: " choice
if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
    exit 1
fi

########### Update package repository index and install updates #################
printf "\n\nUpdating....\n"
apt update -y && apt dist-upgrade -y

########### Package Installation ###############
printf "\n\nInstalling base packages....\n"
apt install curl git build-essential ncdu tmux vim zoxide htop fzf -y
echo 'eval "$(zoxide init --cmd cd bash)' >>/root/.bashrc

printf "\n\nSetting fail2ban...\n"
apt install fail2ban -y
if [ "$?" -eq 0 ]; then
    systemctl enable fail2ban && systemctl start fail2ban
fi
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/jail.local
printf "Done. Config files:\n\t/etc/fail2ban/fail2ban.local\n\t/etc/fail2ban/jail.local\n"

printf "\n\nCerbot installation...\n"
apt install certbot -y

########## Hostname Update ###################
printf "\n\nHostname Setup...\n"
if [ -n "$2" ]; then
    hostnamectl set-hostname "$2"
    echo "127.0.1.1 $2" >>/etc/hosts
    echo "Hostname set to: $2"
else
    echo -e "Hostname unchanged"
fi

########## User Setup ###################
printf "\n\nSetting new user: $1...\n"
if [ -n "$1" ]; then
    useradd -m -G sudo "$1 -s bash"
    passwd "$1"
    if [ "$?" -eq 0 ]; then
        echo "Success."
    else
        echo "passwd exit status: $?"
    fi
    echo 'eval "$(zoxide init --cmd cd bash)"' >>/home/"$1"/.bashrc
else
    echo "No user added!"
fi

########## unattended Updates & Upgrades ############
printf "\n\nInstalling unattended-upgrades....\n"
apt install unattended-upgrades -y

sudo dpkg-reconfigure --priority=low unattended-upgrades
systemctl restart unattended-upgrades

printf "Done. Configure more at: \n\t/etc/apt/apt.conf.d/20auto-upgrades\n\t"
printf "/etc/apt/apt.conf.d/unattended-upgrades\n"

########## SSH Configuration ############
printf "\n\nConfiguring OpenSSH Server....\n"
apt install openssh-server -y
systemctl enable sshd 2>/dev/null || systemctl enable ssh

sshconf=/etc/ssh/sshd_config

cp "$sshconf" /etc/ssh/sshd_config.bak

tmp=$(mktemp)
sed -e 's/^[[:space:]]*#*[[:space:]]*PermitRootLogin[[:space:]]\+.*/PermitRootLogin no/i' \
    -e 's/^[[:space:]]*#*[[:space:]]*PasswordAuthentication[[:space:]]\+.*/PasswordAuthentication no/i' \
    "$sshconf" >"$tmp"

truncate -s 0 /etc/ssh/sshd_config.d/*

chmod --reference="$sshconf" "$tmp" 2>/dev/null || true
chown --reference="$sshconf" "$tmp" 2>/dev/null || true
mv "$tmp" "$sshconf"

echo "::: Important :::"
printf "SSH key setup\n"
printf "\t1. ssh-keygen -t ed25519 -C comment\n"
printf "\t2. ssh-copy-id -i ~/.ssh/key.pub $1@ip\n"
printf "\tConfirm ssh login works(you could possibly lock yourself out). **** Push to $1 ****\n"

unset choice
read -p "Continue? [YES to continue]: " choice
if [ "$choice" != 'YES' ]; then
    echo "Aborting ssh configuration. Please proceed manually"
    cp /etc/ssh/sshd_config.bak "$sshconf"
    exit 1
fi

if command -v systemctl 1>/dev/null 2>&1; then
    systemctl reload ssh 2>/dev/null || systemctl restart ssh
fi

############ Final Reboot #######################
printf "\n\nServer Setup Complete..\n"
unset choice
read -p "Reboot now? [y/N]: " choice
if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
    echo "Further steps: "
    printf "\t1. Lock your root account.\n"
    printf "\t2. Install any other required packages.\n"
    printf "\t3. Customize your jail.local and fail2ban.local files.\n"
    printf "\t4. Setup firewall rules.\n"
    printf "\t5. Customize your unattended-upgrades to automatically remove unused packages.\n"
    printf "\t6. !! Reboot !! after.\n"
    exit 0
fi
echo "Rebooting..."
reboot now
