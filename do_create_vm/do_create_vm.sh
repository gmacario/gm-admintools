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
#       Required:       awk cp fileutils sh tar
#       Optional:       samba
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#       may be overridden by do_create_vm.conf (see comments above)

VM_BCKDIR=/var/tmp/Backup_VM
VM_DESTDIR=${HOME}/tmp

#VM_BCKDATE=20090201
#VM_OLDNAME=Ubuntu804-WR_PFIjan28
#VM_NAME=WR_PFI-macario


# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Program starts here
echo "INFO: $0 - v0.4"

#set -x

# Try to source configuration from conffile
#
conffile=""
if [ -e ./do_create_vm.conf ]; then
    conffile=./do_create_vm.conf
elif [ -e ${HOME}/.do_create_vm/do_create_vm.conf ]; then
    conffile=${HOME}/.do_create_vm/do_create_vm.conf
elif [ -e /etc/do_create_vm.conf ]; then
    conffile=/etc/do_create_vm.conf
else
    echo "WARNING: no conffile found, using defaults"
fi
if [ "${conffile}" != "" ]; then
    echo "INFO: Reading configuration from ${conffile}"
    . ${conffile} || exit 1
fi

# Sanity checks
#
if [ -z ${VM_BCKDIR} ]; then
    echo "ERROR: Should define VM_BCKDIR"
    exit 1
fi
if [ -z ${VM_BCKDATE} ]; then
    echo "ERROR: Should define VM_BCKDATE"
    exit 1
fi
if [ -z ${VM_OLDNAME} ]; then
    echo "ERROR: Should define VM_OLDNAME"
    exit 1
fi
if [ -z ${VM_DESTDIR} ]; then
    echo "ERROR: Should define VM_DESTDIR"
    exit 1
fi
if [ -z ${VM_NAME} ]; then
    echo "ERROR: Should define VM_NAME"
    exit 1
fi

VM_BASELINE=${VM_BCKDATE}-${VM_OLDNAME}

if [ ! -e ${VM_BCKDIR}/${VM_BASELINE} ]; then
    echo "ERROR: Cannot find VM ${VM_BASELINE} under ${VM_BCKDIR}"
    exit 1
fi
if [ -e ${VM_DESTDIR}/${VM_OLDNAME} ]; then
    echo "ERROR: ${VM_OLDNAME} already exists under ${VM_DESTDIR}"
    echo "INFO: Please change ${VM_DESTDIR} or clean its contents"
    exit 1
fi
if [ -e ${VM_DESTDIR}/${VM_NAME} ]; then
    echo "ERROR: ${VM_NAME} already exists under ${VM_DESTDIR}"
    echo "INFO: Please change ${VM_DESTDIR} or clean its contents"
    exit 1
fi
#mkdir -p ${VM_DESTDIR}/${VM_NAME} || exit 1

cd ${VM_BCKDIR}/${VM_BASELINE}
if [ -e md5sum.txt ]; then
    echo "INFO: Verifying backup file checksums..."
    md5sum -c md5sum.txt || exit 1
else
    echo "WARNING: No md5sum.txt in ${VM_BCKDIR}/${VM_BASELINE}"
fi

# Everything seems OK, now unpack VM_BASELINE
#
#cmd_cat="cat ${VM_BASELINE}.tgz"
cmd_cat="cat ${VM_BASELINE}.tgz-[0-9][0-9]"
#
#cmd_untar="tar tvz"
cmd_untar="tar xvz"

echo "INFO: Extracting backup into ${VM_DESTDIR}..."
mkdir -p ${VM_DESTDIR}/${VM_OLDNAME}
retval=$?
if [ $retval -ne 0 ]; then
        echo "ERROR: Cannot create directory under ${VM_DESTDIR}"
        exit 1
fi
(cd ${VM_BCKDIR}/${VM_BASELINE} && ${cmd_cat}) | \
	(cd ${VM_DESTDIR} && ${cmd_untar})
retval=$?
if [ $retval -ne 0 ]; then
        echo "ERROR: Problems extracting files from ${VM_BASELINE}"
        exit 1
fi

# TODO: Should verify that rename of displayname works in all cases...

cd ${VM_DESTDIR}
if [ "${VM_OLDNAME}" != "${VM_NAME}" ]; then
    mv "${VM_OLDNAME}" "${VM_NAME}"
    cd "${VM_NAME}"
    for file in *.vmx; do
	cp $file $file.ORIG
	awk -v vm_name="${VM_NAME}" '
/^display[Nn]ame/	{printf("displayName = \"%s\"\n", vm_name);
			next }
//			{print $0}
' $file.ORIG >$file
    done
fi

echo "INFO: Created new VM ${VM_NAME} under ${VM_DESTDIR}"
echo "INFO: from backup ${VM_BCKDATE} of VM ${VM_BASELINE}"

# === EOF ===
