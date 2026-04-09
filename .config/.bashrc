#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTTIMEFORMAT="[%Y-%m-%d] [%T]  "

# Don't enter commands into the history that start with a space
HISTCONTROL=ignoreboth

alias ls='ls --color=auto'
alias ts='/usr/bin/tailscale'
alias sl=ls
alias grep='grep --color=auto'
alias vim='/usr/bin/nvim'
alias vi=vim
alias sqlite='/usr/bin/sqlite3'
alias gcc='/usr/bin/gcc -pedantic -Wall -Wextra -g -O2'
alias ping='ping -c3 ping.archlinux.org'
alias ccs='codecrafters submit'
alias gpp=g++
alias pvpn=/usr/bin/protonvpn-app
alias signal='signal-desktop --password-wallet="kwallet6"'
alias ncli='nmcli'

alias rm='trash -v' # Safer use.
alias st='speedtest-cli --secure'
alias ll='ls -lFh'
alias la='ls -Fah'
alias lla='ls -lFah'
alias z='zoxide'

alias bthctl='bluetoothctl'

help() {
    echo "Functions: "
    echo -e "\tbcon - Connect the first bluetooth device"
    echo -e "\tbat - Simple battery info into the terminal"
    echo -e "\tvol x - Set volume of the default sink to x%"

    echo -e "\nScripts (/usr/local/bin)"
    echo -e "\tcstart x - start charging when battery drops below x"
}
vol() {
    if [ -z "$1" ]; then
        echo "Usage: vol <percentage>"
        return 1
    fi
    pactl set-sink-volume @DEFAULT_SINK@ "$1%"

    # pactl set-sink-volume sinkname x%
}
# Connect bluetooth earpods.
bcon() {
    if command -v bluetoothctl &>/dev/null; then
        device=$(echo "devices" | bluetoothctl | grep Device | cut -d' ' -f2)
        echo "connect $device" | bluetoothctl
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
PS1='\e[31m[\u@\h \w]\$ >> \e[0m'

set -o noclobber

export EDITOR=/usr/bin/nvim
. "$HOME/.cargo/env"
