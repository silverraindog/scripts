#!/usr/bin/env bash
set -x
source /root/.env
#user is the user to login to the server
#user="root"
#server is the server you want to copy from
#server="hostname"
#sourcepath is the path where the content is on the server
sourcepath="/root/Finished/*"
#destpath is the path on the local server
destpath="/media/other/"
lock="/var/run/rsync.lock"
LOG_FILE="/var/log/rsync/$(date +\%Y\%m\%d).log"

# Function to log messages with a timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

    log_message "starting."
    log_message "Checking lock file"
    if ! [ -f $lock ]; then
        touch $lock
    else
        echo "lock is in place, already running"
        exit
    fi
    log_message "Starting rsync"
    while true; do
        rsync -avz --progress --timeout=60 --partial --remove-source-files $user@$server:"$sourcepath" $destpath
            check=$?
        if [ $check = "0" ]; then
            echo "rsync completed normally"
            exit
        else
            echo "Rsync failure. Backing off and retrying..."
            sleep 180
        fi
    log_message "rsync completed successfully"
    log_message "Chowning $destpath"
        chown -R nobody:nogroup $destpath
    log_message "Chmod $destpath"
        chmod -R 777 $destpath
    log_message "Removing lock file"
        rm -f $lock
     done

log_message "Removing logs older than 7 days"
find /var/log/rsync/ -name "*.log" -mtime +7 -exec rm {} \;