#!/bin/sh

# Description:	Create a new VMware VM starting from a backup

set -x

VM_BCKDIR=/var/tmp/Backup_VM
VM_BCKDATE=20090121
VM_OLDNAME=Ubuntu804-WR_PFIjan19

VM_BASELINE=${VM_BCKDATE}-${VM_OLDNAME}
VM_DESTDIR=${HOME}/tmp
VM_NAME=WR_PFI-macario

mkdir -p ${VM_DESTDIR}/${VM_NAME} || exit 1

if [ ! -e ${VM_BCKDIR}/${VM_BASELINE} ]; then
    echo "ERROR: Cannot find VM ${VM_BASELINE} under ${VM_BCKDIR}"
fi
(cd ${VM_BCKDIR}/${VM_BASELINE}; if [ -e md5sum.txt ]; then
    md5sum -c md5sum.txt
else
    echo "ERROR: Checksums of files on ${VM_BCKDIR}/${VM_BASELINE} do not match"
    exit 1
fi)

# Everything seems OK, now unpack VM_BASELINE
#
cmd_cat="cat ${BCK_OLDNAME}.tgz"
#cmd_cat="cat ${BCK_OLDNAME}.tgz-[0-9][0-9]"
#
cmd_untar="tar tvz"
#cmd_untar="tar xvz"

(cd ${VM_BCKDIR}/${VM_BASELINE} && ${cmd_cat}) | \
	(cd ${VM_DESTDIR} && ${cmd_untar})

#echo "== TODO =="

echo "== Created new VM ${VM_NAME} under ${VM_DESTDIR}"
echo "   from backup ${VM_BCKDATE} of VM ${VM_BASELINE}"

# TODO: Should change VM name into *.vm"

# === EOF ===
