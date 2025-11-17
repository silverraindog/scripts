#!/usr/bin/env bash
set -x

folder=$1
playlist=$2
#playlist="https://www.youtube.com/playlist?list=PLvGjTP9F936rV8jisTJNgab_6YGI3sdq9"
playlist="https://www.youtube.com/playlist?list=$playlist"
#destpath is the path on the local server
destpath="/media/other/youtube-$folder"
lock="/var/run/youtube-$folder.lock"
opt="-x --download-archive $destpath/archive.txt --cookies /root/.cookies.txt"
cmd="/usr/bin/yt-dlp $opt $playlist"
LOG_FILE="/var/log/youtube/$1-$(date +\%Y\%m\%d).log"

# Function to log messages with a timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

    log_message "Script $1 started."
    handle_error() {
        log_message "An error occurred on line $1"
        /bin/rm -f "$lock"
        exit 1
    }
        log_message "Checking if lock is in place"
    trap 'handle_error $LINENO' ERR
    if ! [ -f "$lock" ]; then
        /usr/bin/touch "$lock"
    else
        log_message "lock is in place, already running"
        exit
    fi
    while true
    do

        log_message "Checking if $destpath exists"
    if ! [ -d "$destpath" ]; then
        mkdir -p "$destpath"
    else
        log_message "$destpath exists"
    fi
        cd "$destpath" || exit
        $cmd
    if [ "$cmd" = "0" ] ; then
        log_message "youtube-dl completed normally"
    else
        log_message "youtube failure. Backing off and retrying..."
        sleep 180
    fi
    done
        log_message "Going to chown and chmod $destpath"
        /bin/chown -R nobody:nogroup "$destpath"
        log_message "Chown done"
        log_message "Starting chmod"
        /bin/chmod -R 777 "$destpath"
        log_message "chmod done"
        log_message "removing lock"
        /bin/rm -f "$lock"
        log_message "lock removed"