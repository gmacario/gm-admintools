#!/bin/sh
# Customize WR_PFI-xxxx Virtual Machine
#
# Prerequisites:	nis

set -x

PFI_USER=cerato
PFI_GROUP=cerato
NIS_DOMAIN=lupin.venaria.marelli.it
NIS_SERVERIP=139.128.24.101

# Customize hostname
hostname | grep -e "WRI_PFI-${PFI_USER}"
retval=$?
#echo DBG:retval=$retval
if [ -z $retval ]; then
	echo "INFO: Setting hostname WR_PFI-${PFI_USER}"
	echo "WR_PFI-${PFI_USER}" >/etc/hostname || exit 1
fi

# Bind NIS client to NIS_DOMAIN
which ypwhich || exit 1
ypwhich | grep $NIS_DOMAIN
retval=$?
#echo DBG:retval=$retval
if [ -z $retval ]; then
	echo "INFO: setting NIS domain $NIS_DOMAIN"
	echo "domain $NIS_DOMAIN server $NIS_SERVERIP" >>/etc/yp.conf
fi

# TODO: see wiki
exit 0

# Make sure that user exists

# Change ownership of {/opt/WindRiver,/opt/LUPIN}
for dir in /opt/WindRiver /opt/LUPIN; do
	echo chown -R ${PFI_USER}.${PFI_GROUP} $dir
	chown -R ${PFI_USER}.${PFI_GROUP} $dir || exit 1
done

# === EOF ===
