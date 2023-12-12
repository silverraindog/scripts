#!/bin/bash
start="21:00"
end="06:30"
#user is the user to login to the server
user=""
#server is the server you want to copy from
server=""
#sourcepath is the path where the content is on the server
sourcepath=""
#destpath is the path on the local server
destpath=""

echo "check to see if it's between 9pm and 6am"
currenttime=$(date +%H:%M)
if [[ "$currenttime" > "$start" ]] || [[ "$currenttime" < "$end" ]]; then
    while true
    do
        rsync --bwlimit=500 -avz --progress --timeout=60 --partial $user@$server:$sourcepath $destpath
        check=$?
        if [ $check = "0" ] ; then
            echo "rsync completed normally"
            exit
        else
            echo "Rsync failure. Backing off and retrying..."
            sleep 180
        fi
    done
else
echo "not ready to rsync"
fi

