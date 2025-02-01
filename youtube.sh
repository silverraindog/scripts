#!/usr/bin/env bash
set -x
folder=$1
playlist=$2
playlist="https://www.youtube.com/playlist?list=$playlist"
opt="-x --download-archive $destpath/archive.txt"
#destpath is the path on the local server
destpath="/media/other/youtube-$folder"
lock="/var/run/youtube.lock"

#/*************  ✨ Codeium Command 🌟  *************/
handle_error() {
    echo "An error occurred on line $1" >&2
    logger "An error occurred on line $1"
    /bin/rm -f $lock
    echo "An error occurred on line $1"
    /bin/rm -f $lock
    exit 1
}
#x/******  07d8d3c1-2ca7-45e2-bd0a-af4de4828599  *******/

trap 'handle_error $LINENO' ERR
if ! [ -f $lock ]; then
    /usr/bin/touch $lock
else
    echo "lock is in place, already running"
    exit
fi
while true
do
    mkdir -p "$destpath"
    cd "$destpath" || exit
     if /usr/bin/yt-dlp "$opt" "$playlist"; then
        echo "youtube-dl completed normally"
    else
        echo "youtube failure. Backing off and retrying..."
        sleep 180
    fi
    done
        /bin/chown -R nobody:nogroup "$destpath"
        /bin/chmod -R 777 "$destpath"
        /bin/rm -f $lock