#!/usr/bin/bash

set -e

########### Confirmation ###############
echo -e "Usage: $0 username hostname\n"
read -p "Continue? [y/N]: " choice
if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
    exit 1
fi

########### Update package repository index and install updates #################
printf "\n\nUpdating....\n"
apt update -y && apt dist-upgrade -y && apt autoremove -y

########### Package Installation ###############
printf "\n\nInstalling base packages....\n"
apt install curl git build-essential ncdu tmux vim zoxide htop fzf tree trash-cli -y
echo 'eval "$(zoxide init --cmd cd bash)"' >>/root/.bashrc

printf "\n\nSetting fail2ban...\n"
apt install fail2ban -y
if [ "$?" -eq 0 ]; then
    systemctl enable fail2ban && systemctl start fail2ban
fi
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/jail.local
printf "Done. Config files:\n\t/etc/fail2ban/fail2ban.local\n\t/etc/fail2ban/jail.local\n"

printf "\n\nSetting ufw...\n"
if apt install ufw -y; then
    ufw default deny incoming
    ufw default allow outgoing

    if ufw app list | grep -q "SSH"; then
        ufw allow SSH
        ufw limit SSH
    else
        ufw allow 22/tcp
        ufw limit 22/tcp
    fi

    ufw allow 80/tcp
    ufw allow 443/tcp

    ufw --force enable

    echo "ufw setup complete.."
    ufw status verbose
    echo
else
    echo "Failed setting up ufw."
    exit 1
fi

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
    useradd -m -G sudo "$1" -s /usr/bin/bash
    while [ 1 ]; do
        if passwd "$1"; then
            echo "User was added with sudo privelages..."
            echo -e "\e[32mSuccess.\e[0m"
            break
        fi
    done
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

if systemctl list-unit-files | grep -q '^sshd\.service'; then
    ssh_service=sshd
else
    ssh_service=ssh
fi
systemctl enable --now "$ssh_service"

sshconf=/etc/ssh/sshd_config
backup=/etc/ssh/sshd_config.bak

cp -a "$sshconf" "$backup"

tmp=$(mktemp)
sed -e 's/^[[:space:]]*#*[[:space:]]*PermitRootLogin[[:space:]]\+.*/PermitRootLogin no/I' \
    -e 's/^[[:space:]]*#*[[:space:]]*PasswordAuthentication[[:space:]]\+.*/PasswordAuthentication no/I' \
    "$sshconf" >"$tmp"

chmod --reference="$sshconf" "$tmp" 2>/dev/null || true
chown --reference="$sshconf" "$tmp" 2>/dev/null || true

mv "$tmp" "$sshconf"

echo
echo "================ IMPORTANT ================"
echo "Before continuing, make sure SSH key login works."
echo
echo "1. Generate a key (if needed):"
echo "   ssh-keygen -t ed25519 -C \"comment\""
echo
echo "2. Copy it to the server:"
echo "   ssh-copy-id -i ~/.ssh/id_ed25519.pub $1@<server-ip>"
echo
echo "3. Test logging in with:"
echo "   ssh $1@<server-ip>"
echo
echo "Only continue after confirming key authentication works."
echo "==========================================="
echo

read -r -p "Continue? [YES to continue]: " choice
if [ "$choice" != 'YES' ]; then
    echo "Aborting ssh configuration and restoring previous version. Please proceed manually"
    cp "$backup" "$sshconf"
    exit 1
fi

if ! sudo sshd -t; then
    echo "ERROR: sshd configuration is invalid!"
    echo "Restoring backup..."
    cp -a "$backup" "$sshconf"
    exit 1
fi

systemctl reload "$ssh_service" || systemctl restart "$ssh_service"
echo "SSH configured to accept non-root users with public key Auth.."
echo

#### User bashrc configuration
git clone https://github.com/KaoKsn/scripts-notes.git || true
yes | cp scripts-notes/.config/.bashrc /home/"$1"/.bashrc

echo "Cleaning up.."
echo "Removing unused packages..."
sudo apt autoremove -y

echo "Locking root account..."
sudo passwd -l root

# Setup Completion.
printf "\n\nServer Setup Complete..\n"
unset choice
read -p "Reboot now? [y/N]: " choice
if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
    echo
    echo " Setup complete!"
    echo
    echo "Recommended next steps:"
    echo "  1. Lock the root account."
    echo "  2. Install any additional required packages."
    echo "  3. Review and customize:"
    echo "     - /etc/fail2ban/jail.local"
    echo "     - /etc/fail2ban/fail2ban.local"
    echo "  4. Configure your firewall rules."
    echo "  5. Review unattended-upgrades and enable automatic"
    echo "     removal of unused packages if desired."
    echo "  6. Reboot the system to ensure all changes take effect."
    echo
    echo "======================================================"
    exit 0
fi

echo "Rebooting..."
reboot now
