#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Usage: $0 user [newpass]"
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
' passwd.OLD >passwd.NEW || exit 1

cd /var/yp || exit 1
# make
# sudo -u user

# === EOF ===
