#!/bin/sh


# TODO: Figure out how to encrypt password with salt

if [ $# -lt 1 ]; then
	echo "Usage: $0 user [newpass_crypt]"
	exit 1
fi
user=$1
newpass=$2

ypcat passwd | grep -e "^$user:" >/dev/null
retval=$?
if [ $retval -ne 0 ]; then
    echo "ERROR: User $user not found in NIS database"
    exit 1
fi

cd /var/yp/maps || exit 1

cp passwd passwd.OLD || exit 1

if [ "$newpass" = "" ]; then
    echo "INFO: Resetting password for user $user"
    newpass="GzslqrxRRWFfE"
fi

awk -v user=$user -v newpass=$newpass '
BEGIN	{
	FS=":"
	OFS=":"
	}
$1 == user {
	$2 = newpass;
	print $0;
	next;
	}
//	{
	print $0
	}
' passwd.OLD >passwd || exit 1

cd /var/yp || exit 1
make >/dev/null || exit 1

if [ "$2" = "" ]; then
    echo "INFO: Changing password for user $user"
    sudo -u $user yppasswd
else
    echo "INFO: Changed password for user $user"
    ypcat passwd | grep "^$user:"
fi

exit 0

# === EOF ===
