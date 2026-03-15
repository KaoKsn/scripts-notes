#!/bin/bash

setup_partition() {
    echo -e "Below is the list of recognized block devices\n"
    lsblk
    echo

    read -p "Maintain separate disk for home parition? (y/n): " choice
    if [ "$choice" == 'y' ] || [ "$choice" == 'yes' ]; then
        while [ -z $homedisk ]; do
            read -p "Select disk for home partition: " homedisk
        done
    fi
    echo
    while [ -z $maindisk ]; do
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
}

# Ensure network connectivity.
echo -e "Checking network...\n"
ping -c2 ping.archlinux.org 1>/dev/null || (echo "Ensure you have a working network setup & rerun!" && exit 1)
echo -e "\nNetwork available ! Continuing...\n"

setup_partition
