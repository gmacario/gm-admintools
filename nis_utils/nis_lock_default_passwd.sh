#!/bin/sh

#set -x

for username in `ypcat passwd | awk '
BEGIN	{ FS = ":" }
($2 == "GzslqrxRRWFfE")	{ print $1 }
($2 == "xxx")	{ print $1 }
'`; do
	#echo "DBG:username=$username"
	if [ "$username" != "rodino" ]; then
		echo "DBG: Locking password for user $username"
		#sudo passwd $username
		#sudo su -c passwd $username
		#sudo yppasswd -p $username
		#su -c passwd $username
		#su -c yppasswd $username
		sudo ./nis_set_passwd.sh $username xxx >/dev/null
	fi
done

# === EOF ===
