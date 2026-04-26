#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTTIMEFORMAT="[%Y-%m-%d] [%T]  "
# Don't record commands that start with a space.
HISTCONTROL=ignoreboth

# Core aliases
alias gcc='/usr/bin/gcc -pedantic -Wall -Wextra -g -O2'
alias gp=g++
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lFh'
alias la='ls -Fah'
alias lla='ls -lFah'
alias ncli='nmcli'
alias ping='ping -c3 ping.archlinux.org'
alias sl=ls
alias vi=vim
if [ -f /usr/bin/zoxide ]; then
    alias cd=z
    eval "$(zoxide init bash)"
fi

if [ -f /usr/bin/nvim ]; then
    alias vim='/usr/bin/nvim'
else
    alias vim='/usr/bin/vi'
fi

# Safety aliases.
if [ -f /usr/bin/trash ]; then
    alias rm='trash -v'
else
    alias rm='rm -i'
fi
alias cp='cp -iv'
alias mv='mv -iv'

# Application aliases.
alias ts='/usr/bin/tailscale'
alias sqlite='/usr/bin/sqlite3'
alias pvpn=/usr/bin/protonvpn-app
alias signal='signal-desktop --password-wallet="kwallet6"'
alias st='speedtest-cli --secure'
alias bthctl='bluetoothctl'
alias valgrind='valgrind --track-origins=yes --leak-check=full -s'
alias gdb='gdb -tui'

help() {
    echo "Functions: "
    echo -e "\tbcon 1/0 - Connect the first bluetooth device"
    echo -e "\tbat - Simple battery info into the terminal"
    echo -e "\tvol x - Set volume of the default sink to x%"

    echo -e "\nScripts (/usr/local/bin)"
    echo -e "\tcstart x - start charging when battery drops below x"
}
# Manager volume of the current default sink in command line.
vol() {
    if [ -z "$1" ]; then
        echo "Usage: vol <percentage>"
        return 1
    fi
    if [ -f /usr/bin/pactl ]; then
        pactl set-sink-volume @DEFAULT_SINK@ "$1%"
    else
        echo -e "Looks like you don't have pactl.\n\tInstall either pulseaudio or pipewire!"
    fi
}
# Bluetooth Devices
bcon() {
    if command -v bluetoothctl &>/dev/null; then
        # Default to connect.
        if [ -z "$1" ]; then
            device=$(echo "devices" | bluetoothctl | grep Device | cut -d' ' -f2)
            echo "connect $device" | bluetoothctl
        else
            case "$1" in
            0)
                echo "disconnect" | bluetoothctl 2>/dev/null
                ;;
            1)
                device=$(echo "devices" | bluetoothctl | grep Device | cut -d' ' -f2)
                echo "connect $device" | bluetoothctl
                ;;
            *)
                echo "bcon 0 - Disconnect"
                echo "bcon [1] - Connect"
                ;;
            esac
        fi
    else
        echo "/usr/bin/bluetoothctl: not found. Install using your package manager!"
    fi
}
# Battery info on the terminal.
bat() {
    if [ -d /sys/class/power_supply/BAT0 ]; then
        wd=/sys/class/power_supply/BAT0
        printf "Status: "
        cat $wd/status

        printf "Charge: "
        cat $wd/capacity

        printf "Cycles Elapsed: "
        cat $wd/cycle_count

        printf "Charge control start threshold: "
        cat $wd/charge_control_start_threshold
    else
        echo "Couldn't access the required files"
    fi
}

set -o noclobber

if [ -f /usr/bin/nvim ]; then
    export EDITOR=/usr/bin/nvim
fi

. "$HOME/.cargo/env"

git_branch() {
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
    if [ -z "$branch" ]; then
        return
    else
        echo " {$branch}"
    fi
}

PS1='[\u@\h] (\w)$(git_branch) \$ >> '
