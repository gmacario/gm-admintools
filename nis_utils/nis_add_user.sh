#!/bin/sh
# =============================================================================
# Project:	LUPIN
#
# Description:	Helper script to add users to lupin NIS database
#
# Language:	Linux Shell Script
#
# Usage example:
#       $ ./nis_add_user.sh username displayname [newpass_crypt]
#
# Package Dependencies:
#       Required:       awk sh yp-tools
#	Optional:	?
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

#set -x
set -e

if [ $# -lt 2 ]; then
	echo "Usage: $0 username displayname [newpass_crypt]"
	exit 1
fi
username=$1
displayname=$2
newpass_crypt=$3

#set -x
f_dupe=`ypcat passwd | grep -e "^$username:" | wc -l` >/dev/null
#echo "DBG: f_dupe=$f_dupe"
if [ $f_dupe -gt 0 ]; then
    echo "ERROR: Username $username already present in NIS database"
    exit 1
fi

last_uid=`ypcat passwd | sort -n -t ':' -k 3 -r | head -n 1 | cut -d ':' -f 3`
#echo "DBG: last_uid=$last_uid"

if [ "$newpass_crypt" = "" ]; then
    echo "INFO: Resetting password for username $username"
    newpass_crypt="GzslqrxRRWFfE"
fi

cd /var/yp/maps || exit 1
cp passwd passwd.OLD || exit 1

echo "INFO: Creating new NIS entry:"
echo "INFO:     username:$username"
echo "INFO:     uid=$last_uid"
echo "INFO:     displayname:$displayname"

# Entry with (uid == last_uid) is the template to duplicate

awk \
-v "username=$username" \
-v "displayname=$displayname" \
-v "newpass_crypt=$newpass_crypt" \
-v "last_uid=$last_uid" \
'
BEGIN	{
	FS=":";
	OFS=":";
	}
$3 == last_uid {
	sample_entry=$0;
	next;
	}
//	{
	print $0;
	}
END	{
	# Append new_entry (modeled after sample_entry)
	$0=sample_entry;
	sample_username=$1;
	#
	$1=username;
	$2=newpass_crypt;
	# Keep $3 (uid) as in sample_entry
	# Keep $4 (gid) as in sample_entry
	$5=displayname;
	# Adjust $6 (homedir)
	gsub(sample_username, username, $6);
	# Keep $6 (default_shell) as in sample_entry
	print $0;
	#
	# Leave sample_entry at end (increment uid)
	$0=sample_entry;
	$3=$3+1;
	print $0;
	}
' passwd.OLD >passwd || exit 1

cd /var/yp || exit 1
make >/dev/null || exit 1

echo "INFO: Created entry in NIS:"
ypcat passwd | grep "^${username}:"

#set -x

gid=`ypcat passwd | grep "^${username}:" | cut -d ':' -f 4`
#echo "DBG: gid=${gid}"

# Create and populate Home Directory for new username
mkdir /home/${username} || exit 1
[ -e /etc/skel ] && (cd /etc/skel && cp -a . /home/${username})
chown -R ${username}.${gid} /home/${username} || exit 1

echo "INFO: Created user homedir (/home/${username}):"
ls -la /home/${username}

exit 0

# === EOF ===
