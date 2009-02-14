#!/bin/sh
# Customize WR_PFI-xxxx Virtual Machine
#
# Prerequisites:	nis

set -x

PFI_USER=cerato
PFI_GROUP=cerato

# Customize hostname
#hostname | grep -v -e "WRI_PFI-${PFI_USER}" - && \
	echo "WR_PFI-${PFI_USER}" >/etc/hostname || exit 1

# Link to NIS lupin.marelli.it
which ypwhich || exit 1
echo "domain lupin.venaria.marelli.it server 139.128.24.101" >>/etc/yp.conf

# TODO: see wiki
exit 0

# Make sure that user exists

# Change ownership of {/opt/WindRiver,/opt/LUPIN}
for dir in /opt/WindRiver /opt/LUPIN; do
	echo chown -R ${PFI_USER}.${PFI_GROUP} $dir
	chown -R ${PFI_USER}.${PFI_GROUP} $dir || exit 1
done

# === EOF ===
