#!/usr/bin/env bash

set -e

Color_Off='\033[0m'       # Text Reset
BBlack='\033[1;30m'       # Bold black
UBlack='\033[4;30m'       # Underlined black

repeat() {
    for (( i=1 ; i<=80 ; i++ ));
    do
        printf "$1"
    done
    printf "\n"
}

printf "\n"

figlet PASSWORD

printf "\n"

pass=$(pwgen 64 1 -y)
echo "root:${pass}" | chpasswd
repeat '='
repeat '='
printf "\n${BBlack}Container's root password follows\n\nPLEASE NOTE THIS VALUE - DO NOT INCLUDE IT ANYWHERE IN YOUR REPO\n\n${UBlack}$pass${Color_Off}\n\n"
repeat '='
repeat '='
printf "\n\nContinuing in 20 seconds ...\n\n"
sleep 20

exit 0
