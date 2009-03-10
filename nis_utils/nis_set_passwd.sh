#!/bin/sh


# TODO: Figure out how to encrypt password with salt

if [ $# -lt 1 ]; then
	echo "Usage: $0 user [newpass_crypt]"
	exit 1
fi
user=$1
newpass=$2

cd /var/yp/maps || exit 1

cp passwd passwd.OLD || exit 1

if [ "$newpass" = "" ]; then
    echo "WARNING: Resetting password for $user to default"
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

sudo -u $user yppasswd

#ypcat passwd | grep "^$user:"

# === EOF ===
