#!/bin/sh

#set -x

if [ $# -lt 2 ]; then
	echo "Usage: $0 username displayname [newpass_crypt]"
	exit 1
fi
username=$1
displayname=$2
newpass_crypt=$3

ypcat passwd | grep -v -e "^$username:" >/dev/null
retval=$?
if [ $retval -ne 0 ]; then
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

echo "INFO: Creating new NIS entry (username:$username; uid=$last_uid; displayname:$displayname)"

# Entry with uid=last_uid is the template to duplicate

awk \
-v "username=$username" \
-v "displayname=$displayname" \
-v "newpass_crypt=$newpass_crypt" \
-v "last_uid=$last_uid" \
'
BEGIN	{
	FS=":"
	OFS=":"
	}
$3 == last_uid {
	sample_entry=$0
	next;
	}
//	{
	print $0
	}
END	{
	# New Entry
	$0=sample_entry;
	$5=displayname;
	$2=newpass_crypt;
	$1=username;
	print $0;
	#
	# Sample Entry
	$0=sample_entry;
	$3=$3+1
	print $0;
	}
' passwd.OLD >passwd || exit 1

cd /var/yp || exit 1
make >/dev/null || exit 1

#if [ "$2" = "" ]; then
#    echo "INFO: Changing password for user $user"
#    sudo -u $user yppasswd
#else
#    echo "INFO: Changed password for user $user"
#    ypcat passwd | grep "^$user:"
#fi

exit 0

# === EOF ===
