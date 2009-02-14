#!/bin/sh
# Customize WR_PFI-xxxx Virtual Machine
#
# Prerequisites:	nis

PFI_USER=cerato
PFI_GROUP=users
NIS_DOMAIN=lupin.venaria.marelli.it
NIS_SERVERIP=139.128.24.101

# Customize hostname
hostname | grep -e "WR_PFI-${PFI_USER}" >/dev/null
retval=$?
#echo DBG: retval from hostname=$retval
if [ $retval -ne 0 ]; then
	echo "INFO: Setting hostname WR_PFI-${PFI_USER}"
	echo "WR_PFI-${PFI_USER}" >/etc/hostname || exit 1
fi

# Bind NIS client to NIS_DOMAIN
which ypdomainname >/dev/null || exit 1
ypdomainname | grep $NIS_DOMAIN >/dev/null
retval=$?
#echo DBG: retval from ypdomainname=$retval
if [ $retval -ne 0 ]; then
	echo "INFO: setting NIS domain $NIS_DOMAIN"
	echo "domain $NIS_DOMAIN server $NIS_SERVERIP" >>/etc/yp.conf
	/etc/init.d/nis restart
fi

# Make sure that user exists
id ${PFI_USER} >/dev/null 
retval=$?
#echo DBG: retval from id=$retval
if [ $retval -ne 0 ]; then
	echo "Please append nis to /etc/nsswitch.conf"
	echo "See [[Configuring_NIS_Client_on_LUPIN_Hosts]] on LUPIN wiki"
	exit 1
fi
ypcat passwd | grep -e "^${PFI_USER}:" >/dev/null
retval=$?
#echo DBG: retval from ypcat passwd=$retval
if [ $retval -ne 0 ]; then
	echo "ERROR: user ${PFI_USER} does not exist in NIS $NIS_DOMAIN"
	exit 1
fi

# Make sure that group exists
ypcat group | grep -e "^${PFI_GROUP}:" >/dev/null
retval=$?
#echo DBG: retval from ypcat group=$retval
if [ $retval -ne 0 ]; then
	echo "ERROR: group ${PFI_GROUP} does not exist in NIS $NIS_DOMAIN"
	exit 1
fi

#set -x

# Create home directory for PFI_USER
new_homedir=`ypcat passwd | grep -e "^${PFI_USER}:" | cut -d ':' -f 6`
#echo "DBG: new_homedir=$new_homedir"

mkdir $new_homedir
cd /etc/skel && cp -a . $new_homedir

# Change ownership of relevant files
for dir in $new_homedir /opt/WindRiver /opt/LUPIN; do
	echo chown -R ${PFI_USER}.${PFI_GROUP} $dir
	chown -R ${PFI_USER}.${PFI_GROUP} $dir || exit 1
done

# TODO: see wiki
exit 0

# === EOF ===
