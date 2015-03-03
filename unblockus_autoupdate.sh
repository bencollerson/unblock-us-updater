#!/bin/sh
#
# Unblock-Us Update-Script
#
# This script automatically sends your current IP adress to the Unblock-Us api.
# It can be used to update your IP adress via cron.
#
# (modified by bencollerson)
#
# Author:       Timo Schlueter, Tjark Saul
# Mail:         me@timo.in
# Web:          www.timo.in, tjarksaul.de
#
# Version:      0.3
# Date:         2015-03-03
#
# Notes:        I am not affiliated with Unblock-Us
#

# Variables (user specific)
userlogin="email@example.com"
userpassword="password"
ipaddressurl="http://icanhazip.com"
ipaddressfile="/tmp/ip.txt"

# Environment
apiurl="https://api.unblock-us.com/login?$userlogin:$userpassword"
wgetcmd=$(which wget)

# IP addresses
oldip=`cat $ipaddressfile 2> /dev/null || echo -n`
currip=`$wgetcmd -qO- "$ipaddressurl"`

if [ "$oldip" = "$currip" ]; then
	# our ip address did not change, so we will exit now
	exit 0
else
	echo "$currip" > $ipaddressfile
fi

# if we are at this point, our ip address did change
# Check if username and password are set.
if [ -z $userlogin ]; then
	echo "No username set."
	exit 1
elif [ -z $userpassword ]; then
	echo "No password set."
	exit 1
else
	# Call the api
	response=$($wgetcmd --no-check-certificate -qO- $apiurl)

	# Check response from api
	if [ "$response" = "active" ]; then
		echo "IP address is active. You are good to go!"
		exit 0
	elif [ "$response" = "bad_password" ]; then
		echo "Wrong username or password."
		exit 1
	elif [ "$response" = "not_found" ]; then
		echo "Username not found."
		exit 1
	else
		echo "Unknown error. Check api url or documentantion."
		exit 1
	fi
fi
