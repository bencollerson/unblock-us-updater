#!/bin/sh
#
# Unblock-Us Update-Script
#                                                                              
# This script automatically sends your current IP adress to the Unblock-Us api.
# It can be used to update your IP adress via cron.
#                             
# Author:       Timo Schlueter, Tjark Saul
# Mail:         me@timo.in       
# Web:          www.timo.in, tjarksaul.de
#                  
# Version:      0.3      
# Date:         19-12-2014
#                                                                         
# Notes:        I am not affiliated with Unblock-Us
#
                           
# Variables (user specific)
userlogin="email@example.com"
userpassword="password"
          
# Environment                                                    
apiurl="https://api.unblock-us.com/login?$userlogin:$userpassword"
wgetcmd=$(which wget)

# IP addresses
oldip=`cat ip.txt`
currip=`curl -s "http://icanhazip.com/"`

if [ $oldip == $currip ]; then
    # our ip address did not change, so we will exit now
    exit 0
fi

# if we are at this point, our ip address did change
# Check if username and password are set.
if [ -z $userlogin ]
        then                           
                echo "No username set."
                exit 1   
elif [ -z $userpassword ]
        then                           
                echo "No password set."
                exit 1
else                  
        # Call the api                                          
        response=$($wgetcmd --no-check-certificate -qO- $apiurl)
        
	# Check response from api   
        if [ "$response" = "active" ]; then                                                   
                        echo "IP address is active. You are good to go!"
                        echo $currip > ip.txt
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
