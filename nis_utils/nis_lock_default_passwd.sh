#!/bin/sh

#set -x

for username in `ypcat passwd | awk '
BEGIN	{ FS = ":" }
($2 == "GzslqrxRRWFfE")	{ print $1 }
#($2 == "xxx")	{ print $1 }
($2 == "yyy")	{ print $1 }
'`; do
	#echo "DBG:username=$username"
	if [ "$username" != "rodino" ]; then
		echo "TODO: Lock password for user $username"
		##TODO: sudo ./nis_set_passwd.sh $username xxx >/dev/null
	fi
done

# === EOF ===
