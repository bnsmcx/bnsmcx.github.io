#!/usr/bin/bash

# initialize options
auto_secure='false'
set_aliases='false'
show_help='false'
quarantine='false'
set_passwords='false'
lock_firewall='false'
set_interfaces='false'

while getopts ':pdahqfi' option; do
  case "$option" in
    'p') set_passwords='true';;
    'd') auto_secure='true';;
    'a') set_aliases='true';;
    'h') show_help='true';;
    'q') quarantine='true';;
    'f') lock_firewall='true';;
    'i') set_interfaces='true';;
  esac
done

if [ "$auto_secure" = false ] && [ "$set_aliases" = false ] && [ "$quarantine" = false ] && [ "$set_passwords" = false ] && [ "$lock_firewall" = false ] && [ "$set_interfaces" = false ]; then
	show_help='true'
fi

if [ "$show_help" = true ]; then

    echo ''
    echo 'Options are:'
    echo ''
    echo '    -p set_passwords    -- sets every user'\'s' password: "sudo ccdc-linux.sh -p newP@ssw0rd"'
    echo '    -d auto_secure      -- default initial securing of the system'
    echo '    -a set_aliases      -- sets and displays alias for useful bash one-liners'
    echo '    -h show_help        -- this'
    echo '    -q quarantine       -- moves all files owned by a user into their home directory and then zips it: "sudo ccdc-linux.sh -q user"'
    echo '    -f lock_firewall    -- completely locks down the firewall, all services will be affected'
    echo '    -i set_interfaces   -- quickly sets all interfaces up/down: "sudo ccdc-linux.sh -i down" -or- "sudo ccdc -i down"'
fi

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!" && echo
	exit
fi

# Defining and exporting aliases for useful one-liner commands
if [ "$set_aliases" = true ]; then
	
	BLUE 'Aliases set...'
	echo

	GREEN 'Searches the entire filesystem for '\''searchWord'\'' sends errors to /dev/null:'
	GREEN 'Usage: "$f searchTerm"'
	echo 'alias f=find / 2>/dev/null | grep'
	alias f='find / 2>/dev/null | grep'
	echo
	
	GREEN 'Removes all files matching a given target name, wildcards are in play, case sensitive'
	GREEN 'Usage: "$nuke target*"'
	sudo find / -name "*target*" -exec rm -rf {} \;

	# Find every file or folder owned by 'USER_NAME' and move them into a single archive
	# Some versions of xargs will need '-i%' as the syntax for the xargs varible
	echo USER_NAME | xargs -I % sh -c 'find / -type f -user % -exec mv {} /home/% \; && zip -r /home/%.zip /home/% && rm -r /home/%'

	# Find and kill every process owned by 'USER_NAME'
	pkill -9 -u `id -u USER_NAME`

	# Set all interfaces up or down
	ip a | grep mtu | cut -d":" -f2 | xargs -I % ip link set % u
fi

# set passwords for all users on the system
if [ "$set_passwords" = true ]; then
	BLUE 'Test trigger $set_passwords'
fi

# auto_secure performs all default actions to lock down the box 
if [ "$auto_secure" = true ]; then
	BLUE 'Test trigger $auto_secure'
fi

# Move all files owned by a user to their home directory and zip it
if [ "$quarantine" = true ]; then
	BLUE 'Test trigger $quarantine'
fi

# Completely lock down the firewall, this will interrupt all services
if [ "$lock_firewall" = true ]; then
	BLUE 'Test trigger $lock_firewall'
fi

# Set all interfaces either up or down
if [ "$set_interfaces" = true ]; then
	BLUE 'Test trigger $set_interfaces'
fi
