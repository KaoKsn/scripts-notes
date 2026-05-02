#!/bin/bash

if ![ -f /usr/bin/gcc ]; then
    sudo pacman -S gcc
    if [ "$?" -ne 0 ]; then
        echo "GCC installation failed!"
        exit 1
    fi
fi
if ![ -f /usr/bin/make ]; then
    sudo pacman -S make
    if [ "$?" -ne 0 ]; then
        echo "GNU make installation failed!"
        exit 1
    fi
fi
if ![ -f /usr/bin/git ]; then
    sudo pacman -S git
    if [ "$?" -ne 0 ]; then
        echo "git installation failed!"
        exit 1
    fi
fi

base=$(pwd)

mkdir -p "$proj_target"
cd "$proj_target"
git init

mkdir src/ include/ test/
cat "$(pwd)/boilerplate.c" >>./src/main.c

touch .gitignore
echo "$(pwd)/gitignore" >>/.gitignore

touch README.md
echo "$(pwd)/LICENSE" >>./LICENSE

echo "Generating the makefile..."
echo "$(pwd)/makefile" >>./makefile
