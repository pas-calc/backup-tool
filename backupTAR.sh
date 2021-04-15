#!/bin/bash

### Pascal // 15/APRIL/2021

echo "BACKUP"
echo "------"
echo ""

currentDate=`date`
foldername=$(date +"%Y%m%d")
echo "Started at: ${currentDate}"
echo "Folder Name: ${foldername}"
echo ""

#~cd ~
pwd

read -p "Path of Backup (directory will be created inside this): " targetpath
echo "use: targetpath = ${targetpath}"
targetpath2="${targetpath}/backup${foldername}"
echo "use: targetpath2 = ${targetpath2}"
echo ""
mkdir -p "${targetpath2}"

#~https://unix.stackexchange.com/a/61936 (Redirect all subsequent commands' stderr using exec)
exec > >(tee "$targetpath2/backup_log.log") 2>&1
echo -en "Date: " && date && echo ""


#~find . -maxdepth 1 -type d ! -path .  -not -path '*/\.*' -not -path "./Downloads" -not -path "./Schreibtisch" -not -path "./Öffentlich"  -print0 | while read -d $'\0' file
find ~ -mindepth 1 -maxdepth 1 -type d ! -path .  -not -path '*/\.*'   -print0 | while read -d $'\0' file
do
#for dir in $(ls -d */); do
	dir="$file"
	echo " ### FOLDER ${dir}"

	# get basename (strip /home/user/...)
	CLEAN=$(basename $dir)
	# first, strip underscores
	CLEAN=${CLEAN//_/}
	# next, replace spaces with underscores
	CLEAN=${CLEAN// /_}
	# now, clean out anything that's not alphanumeric or an underscore
	CLEAN=${CLEAN//[^a-zA-Z0-9_]/}
	# finally, lowercase with TR
	CLEAN=`echo -n $CLEAN | tr A-Z a-z`

	echo "dirname:  ${CLEAN}"
	targetdir="${targetpath2}/backup-${CLEAN}.tar.gz"
	echo "fullname: ${targetdir}"

	#~https://help.ubuntu.com/community/BackupYourSystem/TAR (BackupYourSystem/TAR - Community Help Wiki)
	tar -cpzf "${targetdir}" --one-file-system   "$dir"
	echo ""

done

echo ""
echo "done."
echo ""
date
echo ""
echo "---------------"
echo ""
echo "RUN: BACKUP ADDITIONAL SETTINGS"
./backup_settings.sh "${targetpath2}"
echo ""
echo ""
echo "---------------"
read -p "Press enter to exit"
