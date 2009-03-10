#!/bin/sh


# TODO: Figure out how to encrypt password with salt

if [ $# -lt 1 ]; then
	echo "Usage: $0 user [newpass_crypt]"
	exit 1
fi

cd /var/yp/maps || exit 1

cp passwd passwd.OLD || exit 1

awk -v user=$1 -v newpass=$2 '
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
make || exit 1
# sudo -u user

# === EOF ===
