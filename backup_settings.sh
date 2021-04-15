#!/bin/bash

### save additional settings in backup
### Pascal // 15/APRIL/2021

echo "Save settings"
echo "-------------"

###

# check if target dir is set
if [ -z $1 ]; then
    echo "The first argument is not set"
    exit 1
else
    echo "target directory: '$1'"
fi

# check if it is a valid dir
if [ ! -d "$1" ]
then
    echo "$1 does NOT exist on your filesystem."
    exit 1
fi

echo "--------------------------------------"
exec > >(tee "$1/backup_additional.log") 2>&1
echo "--------------------------------------"
echo "TARGET = $1"
echo "--------------------------------------"
echo ""
echo ""


# start doing things (you can append code below)

#~https://askubuntu.com/a/194438
echo "Screenshot"
import -window root  "$1/screenshot.png"
echo "return state: $?"
echo ""

#~https://ostechnix.com/backup-and-restore-linux-desktop-system-settings-with-dconf/
echo "Settings (dconf: Panel, keyboard shortcuts, and many more layout depending stuff)"
dconf dump / >  "$1/dconf_dump.txt"
echo "return state: $?"
echo ""

#~https://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages
echo "list installed program packages"
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) >  "$1/installed_programs.txt"
echo "return state: $?"
echo ""

#~https://stackoverflow.com/a/35570937
#~https://askubuntu.com/a/299280
# alternatively, in Firefox do a manual export of bookmarks in JSON or HTML format
echo "Firefox Bookmarks"
ffbookmarks="$(find ~/.mozilla/firefox/*.default*/bookmarkbackups | sort | tail -n1)"
if [ -n "$ffbookmarks" -a -f "$ffbookmarks" ]; then
    echo "bookmarks file: '$ffbookmarks'"
    ffbookmarks_basename="$(basename  $ffbookmarks)"
    echo "basename: '$ffbookmarks_basename'"
    cp "$ffbookmarks" "$1/$ffbookmarks_basename"
    #~https://github.com/Unode/firefox_decrypt (alternatively for plain text export)
    echo "copy logins and passwords"
    cp $(find ~/.mozilla/firefox/*.default*/logins.json | sort | tail -n1) "$1"
    cp $(find ~/.mozilla/firefox/*.default*/key* | sort | tail -n1) "$1"
fi
echo "last return state: $?"
echo ""

