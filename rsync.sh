#!/usr/bin/env bash
set -x
start="21:00"
end="06:30"
#user is the user to login to the server
user="root"
#server is the server you want to copy from
server="cronus.sargus.co.za"
#sourcepath is the path where the content is on the server
sourcepath="/root/Finished/*"
#destpath is the path on the local server
destpath="/media/other/"
lock="/var/run/rsync.lock"

echo "check to see if it's between 9pm and 6am"
currenttime=$(date +%H:%M)
if [[ "$currenttime" > "$start" ]] || [[ "$currenttime" < "$end" ]]; then
    if ! [ -f $lock ]; then
        touch $lock
    else
        echo "lock is in place, already running"
        exit
    fi
    while true; do
        # rsync --bwlimit=500 -avz --progress --timeout=60 --partial $user@$server:$sourcepath $destpath
        rsync -avz --progress --timeout=60 --partial $user@$server:"$sourcepath" $destpath
        check=$?
        if [ $check = "0" ]; then
            echo "rsync completed normally"
            exit
        else
            echo "Rsync failure. Backing off and retrying..."
            sleep 180
        fi
        chown -R nobody:nogroup $destpath
        chmod -R 777 $destpath
        rm -f $lock
    done
else
    echo "not ready to rsync"
fi
