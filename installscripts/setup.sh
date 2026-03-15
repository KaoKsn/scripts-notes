#!/bin/bash

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
    echo "2. Make sure your system meets the minimum hardware requirements:"
    echo "   - Processor: x86_64 CPU"
    echo "   - RAM: [Minimum 512 MB]"
    echo "   - Disk Space: [Minimum 2 GB]"
    echo "3. Ensure that the installation media uses a genuine copy of the iso."
    echo "4. Verify that you have a stable power supply during the installation process."
    echo "6. Follow the prompts carefully during the installation."
    echo "\nProceeding with the installation...\n"
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
    fi
    echo
    while [ -z $maindisk ] || ! [ -b $maindisk ]; do
        printf "Select your main disk for partition: "
        read maindisk
    done

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
    fi
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
