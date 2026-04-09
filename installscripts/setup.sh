#!/bin/bash

declare -a disks

ensure_network_connectivity {
    # Ensure network connectivity.
    echo -e "Checking network...\n"
    ping -c2 ping.archlinux.org 1>/dev/null || (echo "Ensure you have a working network setup & rerun!" && exit 1)
    echo -e "\nNetwork available ! Continuing...\n"
}

# Pre-Installation Note
print_notes() {
    echo "=========================================="
    echo "IMPORTANT: Please Read Before Installation"
    echo "=========================================="
    echo "1. Ensure that you have BACKED UP all important data."
    echo "2. Ensure that all your hardware works as expected using the live boot features"
    echo "3. Make sure your system meets the minimum hardware requirements:"
    echo "   - Processor: x86_64 CPU"
    echo "   - RAM: [Minimum 512 MB]"
    echo "   - Disk Space: [Minimum 2 GB]"
    echo "4. Ensure that the installation media uses a genuine copy of the iso."
    echo "5. Verify that you have a stable power supply during the installation process."
    echo "6. Follow the prompts carefully during the installation."
    echo -e "\nProceeding with the installation in 3s...\n"
    for i in {1..3}; do
        echo -e "$i..";
        sleep 1
    done
}

setup_partition() {
    echo -e "Below is the list of recognized block devices\n"
    lsblk
    echo

    read -p "Maintain separate disk for home parition? (y/n): " choice
    if [ "$choice" == 'y' ] || [ "$choice" == 'yes' ]; then
        while [ -z $homedisk ] || ! [ -b $homedisk ]; do
            read -p "Select disk for home partition: " homedisk
        done
        disks[1]="$homedisk"
    fi
    echo
    while [ -z $maindisk ] || ! [ -b $maindisk ]; do
        printf "Select your main disk for partition: "
        read maindisk
    done
    disks[0]="$maindisk"

    unset choice

    while [ "$choice" != "YES" ]; do
        printf "Paritioning is DESTRUCTIVE....GO AHEAD? (YES/NO): "
        read choice
    done
    clear
    for i in {5..1}; do
        printf "Paritioning in $i..\r"
        sleep 1
    done
    echo

    if [ "$1" -eq 64 ]; then
        echo "Going ahead with the GPT scheme"
        wipefs -a "$maindisk"
        echo "Writing zeroes to the $maindisk...."
        dd if=/dev/null of="$maindisk" bs=4M status=progress

        if ! [ -z "$homedisk" ]; then
            wipefs -a "$homedisk"
            echo "Writing zeroes to $homedisk...."
            dd if=/dev/null of="$homedisk" bs=4M status=progress
        fi
        swap_space=$(expr $(free -m | sed -n '2p' | tr -s [:space:] | cut -d' ' -f2 ) / 2)
    fi
}

mount_and_boostrap() {
    mount /dev/"$maindisk"p2 /mnt
    mount /dev/"$maindisk"p1 /mnt/boot/efi --mkdir
    if [ -z "$homedisk" ]; then
        mount /dev/"$maindisk"p3 /mnt/home --mkdir
        mkswap /dev/"$maindisk"p4
        swapon /dev/"$maindisk"p4
    else
        mkswap /dev/"$maindisk"p3
        swapon /dev/"$maindisk"p3
    fi
    echo "=========================================="
    echo "           Select Kernels                 "
    echo "=========================================="
    echo "1) linux"
    echo "2) linux-lts"
    echo "2) linux-hardened"
    echo "4) linux-zen"
    echo "5) Exit"
    echo "=========================================="
    declare -a list packages
    while true; do
        unset num
        while [ -z "$num" ]; do
            read -p "Choice: " gpu_num
        done
        case "$num" in
            1)
                list+=("Linux");
                packages+=("linux");;
            2)
                list+=("LTS kernel");
                packages+=("linux-lts");;
            3)
                list+=("Hardened");
                packages+=("linux-hardened")
            4)
                list+=("Zen");
                packages+=("linux-zen")
            *)
                echo "${list[@]}: Kernel List, ${packages[@]}: packages"
                read -p "Run it back? (y/n): " choice
                if [ "$choice" == 'n' ]; then
                    break
                else
                    unset list packages
                    echo -e "\nReselect your choices\n"
                fi
                ;;
        esac
    done

    echo "Bootstrapping..."
    pacstrap -K -i /mnt base "${packages[@]}"
    echo -e "\nDone"

    echo -e "\nGenerating /etc/fstab...\n"
    genfstab -U -p /mnt >> /mnt/etc/fstab
    echo -e "Verify fstab file.\n\tblkid could be of help!.."
    cat /mnt/etc/fstab

    read -p "Continue?(y/n): " choice
    if [ "$choice" == 'n' ] || [ "$choice" == 'no' ]; then
        echo -e "\e[31mAborting...\e[0m"
        exit 1
    fi
}

chroot_n_config() {
    export dir_chroot=/mnt
    arch-chroot /mnt

    echo "KEYMAP=us" >> /etc/vconsole.conf

    read -p "Hostname: " hostname
    echo "$hostname" > /etc/hostname

    echo -e "\nSetting timezone info to: Asia/Kolkata"
    ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
    hwclock --systohc

    echo -e "\nGenerating locales...\n"
    cat /etc/locale.gen | grep "en_US-UTF-8 UTF-8" | sed -i 's/#//g'
    locale-gen
}

setup_users() {
    echo -e "\nSetup a User"
    while [ -z "$user" ]; do
        read -p "Username: "
    done
    useradd -m -g users "$user"

    echo -e "\nProvide a strong password (you won't see the password. Don't worry)"
    while [ -z "$user" ]; do
        read -sp "Password: " pass
    done
    yes "$pass" | passwd "$user"

    echo
    for i in {1..3}; do
        read -p "Try $i: Allow all previlages to $user? (y/n) " choice
        if [ "$choice" == 'y' ] || [ "$choice" == 'yes' ]; then
            usermod -G wheel "$user"
            break
        fi
    done

    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

    echo -e "\nSet root password"
    while [ -z "$rootpass" ]; do
        read -sp "Root password: " rootpass
    done
    yes "$rootpass" | passwd root
}

setup_dirvers () {
    echo -e "\n** lscpi can help detect your hardware **\n"
    echo "=========================================="
    echo "           Select Your GPU                "
    echo "=========================================="
    echo "1) AMD"
    echo "2) Intel"
    echo "3) NVIDIA"
    echo "4) Exit"
    echo "=========================================="
    declare -a list packages
    while true; do
        unset gpu_num
        while [ -z "$gpu_num" ]; do
            read -p "Choice: " gpu_num
        done
        case "$gpu_num" in
            1)
                list+=("AMD");
                packages+=("mesa" "libva-mesa-driver");;
            2)
                list+=("Intel");
                packages+=("mesa" "intel-media-driver");;
            3)
                list+=("Nvidia");
                packages+=("nvidia-open" "nvidia-open-dkms" "nvidia-utils")
                pacman -Qi linux-lts &>/dev/null
                if [ "$?" -eq 0 ]; then
                    packages+=("nvidia-open-lts")
                fi
            *)
                echo "${list[@]}: GPU List, ${packages[@]}: packages"
                read -p "Run it back? (y/n): " choice
                if [ "$choice" == 'n' ]; then
                    break
                else
                    unset list packages
                    echo -e "\nReselect your choices\n"
                fi
                ;;
        esac
    done

    echo -e "Installing firmware packages"
    pacman -S linux-firmware
}

install_essentials() {
    pacman -S networkmanager openssh e2fsprogs dosfstools mtools neovim ncdu cronie pciutils docker
    systemctl enable NetworkManager

    # Build tools.
    pacman -S cmake curl ninja base-devel git

    echo
    read -p "Enable sshd during system startup? (y/n): " choice
    if [ "$choice" == 'y' ] || [ "$choice" == 'yes' ]; then
        systemctl enable sshd
    fi

    # Set up nvim
    echo "Setting up neovim"
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    echo "Setting up KDE Desktop"
    pacman -S plasma-desktop dolphin firefox konsole okular mpv sddm 
    systemctl enable sddm

    echo; unset choice
    read -p "Install office productivity tools(y/n): " choice
    if [ "$choice" == 'y' ] || [ "$choice" == 'yes' ]; then
        pacman -S libreoffice-fresh
    fi
}

setup_bootloader() {
    pacman -S grub efibootmgr os-prober
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux
    grub-mkconfig -o /boot/grub/grub.cfg
    mkinticpio -P

    echo "Installation Complete. Rebooting now"
    exit
    umount -a &>/dev/null
    shutdown -r now
}

efi_bit=$(cat /sys/firmware/efi/fw_platform_size 2>/dev/null || echo 0)
if [ "$efi_bit" -eq 64 ]; then
    echo "64 bit UEFI mode"
else if [ "$efi_boot" -eq 32 ]
    echo "$efi_bit UEFI boot. Use Arch Linux 32 or any other distro that support 32 bit systems"
else
    echo "Legacy BIOS boot detected!"
fi

timedatectl
ensure_network_connectivity; echo

print_notes

setup_partition $efi_bit

mount_and_boostrap

chroot_n_config

setup_users

setup_drivers

install_essentials

setup_bootloader
