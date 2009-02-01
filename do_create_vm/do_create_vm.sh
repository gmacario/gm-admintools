#!/bin/sh
# =============================================================================
# Project:      LUPIN
#
# Description:	Create a new VMware VM starting from a backup
#
# Language:     Linux Shell Script
#
# Usage example:
#       $ ./do_create_vm.sh
#
# The script attempts to fetch configuration options
# from the first file in the following search list:
#       * ./do_create_vm.conf
#       * ${HOME}/.do_create_vm/do_create_vm.conf
#       * /etc/do_create_vm.conf
#
# Package Dependencies:
#       Required:       awk cp fileutils samba sh tar
#       Optional:       ?
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#       may be overridden by do_create_vm.conf (see comments above)

VM_BCKDIR=/var/tmp/Backup_VM
VM_BCKDATE=20090201
VM_OLDNAME=Ubuntu804-WR_PFIjan28

VM_BASELINE=${VM_BCKDATE}-${VM_OLDNAME}
VM_DESTDIR=${HOME}/tmp
VM_NAME=WR_PFI-macario

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Program starts here
echo -e "$0 - v0.2\n"

#set -x

if [ ! -e ${VM_BCKDIR}/${VM_BASELINE} ]; then
    echo "ERROR: Cannot find VM ${VM_BASELINE} under ${VM_BCKDIR}"
fi
if [ -e ${VM_DESTDIR}/${VM_OLDNAME} ]; then
    echo "ERROR: ${VM_OLDNAME} already exists under ${VM_DESTDIR}"
    echo "       Please change ${VM_DESTDIR} or clean its contents"
    exit 1
fi
if [ -e ${VM_DESTDIR}/${VM_NAME} ]; then
    echo "ERROR: ${VM_NAME} already exists under ${VM_DESTDIR}"
    echo "       Please change ${VM_DESTDIR} or clean its contents"
    exit 1
fi
#mkdir -p ${VM_DESTDIR}/${VM_NAME} || exit 1

(cd ${VM_BCKDIR}/${VM_BASELINE}; if [ -e md5sum.txt ]; then
    echo "*** Verifying backup file checksums..."
    md5sum -c md5sum.txt
else
    echo "ERROR: Checksums of files on ${VM_BCKDIR}/${VM_BASELINE} do not match"
    exit 1
fi)

# Everything seems OK, now unpack VM_BASELINE
#
#cmd_cat="cat ${VM_BASELINE}.tgz"
cmd_cat="cat ${VM_BASELINE}.tgz-[0-9][0-9]"
#
#cmd_untar="tar tvz"
cmd_untar="tar xvz"

echo "*** Extracting backup into ${VM_DESTDIR}..."
(cd ${VM_BCKDIR}/${VM_BASELINE} && ${cmd_cat}) | \
	(cd ${VM_DESTDIR} && ${cmd_untar})

#echo "== TODO =="

echo "== Created new VM ${VM_NAME} under ${VM_DESTDIR}"
echo "   from backup ${VM_BCKDATE} of VM ${VM_BASELINE}"

#set -x

cd ${VM_DESTDIR}
if [ "${VM_OLDNAME}" != ${VM_NAME} ]; then
    mv "${VM_OLDNAME}" "${VM_NAME}"
    cd "${VM_NAME}"
    for file in *.vmx; do
	cp $file $file.ORIG
	awk -v vm_name="${VM_NAME}" '
/^displayName/	{printf("displayname = \"%s\"\n", vm_name);
		next }
//		{print $0}
' $file.ORIG >$file
    done
fi

# TODO: Should change VM name into *.vm"

# === EOF ===
