#!/bin/sh
# =============================================================================
# Project:	LUPIN
#
# Description:	Backup a VMware VM and copy to a remote directory on NAS
#
# Language:	Linux Shell Script
#
# Usage example:
#       $ ./vm_backup.sh
#
# The script attempts to fetch configuration options
# from the first file in the following search list:
#       * ./vm_backup.conf
#       * ${HOME}/.vm_backup.conf
#       * /etc/vm_backup.conf
#
# Package Dependencies:
#       Required:       awk cp fileutils samba sh
#	Optional:	?
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#       may be overridden by do_clone_disk.conf (see comments above)

# NAS Share used to save backups
NAS_SHARE=//itven1nnas1.venaria.marelli.it/lupin
#
# Active Directory credentials (domain/user/password) on NAS_SHARE
NAS_DOMAIN=mmemea
#NAS_USER=paolodoz
#NAS_PASSWORD=MyPassword
#
# Directory under NAS_SHARE where to save backup
NAS_BACKUPDIR=/Backup_VM

# Directory where backup is created before uploading to NAS
#BCK_TMPDIR=${HOME}/tmp/${NAS_BACKUPDIR}
BCK_TMPDIR=/var/tmp/${NAS_BACKUPDIR}

# Repository containing VM
VM_REPOSITORY="/var/lib/vmware/Virtual Machines"
#
# Name of the VM to backup
#VM_NAME=Ubuntu804-WR_PFIjan19
#VM_NAME=lupin07

# The following options are still unused:
#NAS_MOUNTPOINT=/mnt/lupin
#NAS_RELEASEDIR=/Master_Disks/Build_VM
#NAS_CHECKFILE=${NAS_MOUNTPOINT}/this_is_itven1nnas1_lupin.txt

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
if [ -e ./vm_backup.conf ]; then
    conffile=./vm_backup.conf
elif [ -e ${HOME}/.vm_backup.conf ]; then
    conffile=${HOME}/.vm_backup.conf
elif [ -e /etc/vm_backup.conf ]; then
    conffile=/etc/vm_backup.conf
else
    echo "WARNING: No conffile found, using defaults"
fi
if [ "${conffile}" != "" ]; then
    echo "INFO: Reading configuration from ${conffile}"
    . ${conffile} || exit 1
fi

#set -x

# Export conf variables to child processes
#export VM_NAME

# Those parameters should not usually be changed



# NOTE: --bytes=xxx syntax of split has changed between ver 5.x and 6.x
# Consult your manpage if you have any problems
BCK_CHUNKSIZE=2048m
#BCK_CHUNKSIZE=4500M

## Request parameters if not specified in the section above
if [ "${BCK_TMPDIR}" = "" ]; then
    read -p "Enter BCK_TMPDIR: " VM_NAME
fi
if [ "${VM_NAME}" = "" ]; then
    read -p "Enter VM_NAME: " VM_NAME
fi
BCK_FILENAME=`date +%Y%m%d`-${VM_NAME}
if [ "${OPT_EXPORT_TO_NAS}" = "true" ]; then
    if [ "${NAS_USER}" = "" ]; then
        read -p "Enter NAS_USER: " NAS_USER
    fi
    if [ "${NAS_PASSWORD}" = "" ]; then
        echo -n "Enter NAS_PASSWORD: "
        stty -echo
        read NAS_PASSWORD
        echo
        stty echo
    fi
fi

# Sanity checks
if [ ! -d "${VM_REPOSITORY}/${VM_NAME}" ]; then
    echo ERROR: Cannot find VM "${VM_NAME}" under "${VM_REPOSITORY}"
    exit 1
fi

# Make sure you can write your temporary files...
f_newcreated=false
if [ ! -e ${BCK_TMPDIR}/${BCK_FILENAME} ]; then
    # Directory oes not exist, create it
    mkdir -p ${BCK_TMPDIR}/${BCK_FILENAME}
    if [ $? -gt 0 ]; then
        echo "ERROR: Cannot create directory under ${BCK_TMPDIR}"
        exit 1
    fi
    f_newcreated=true
fi

cd ${BCK_TMPDIR}/${BCK_FILENAME} || exit 1

if [ -e md5sum.txt ]; then
    echo "WARNING: skipping creation of ${BCK_FILENAME}"
else
    # Make sure that VM is stopped
    VM_ISLOCKED=`find "${VM_REPOSITORY}/${VM_NAME}" -name "*.lck" | wc -l`
    if [ ${VM_ISLOCKED} -gt 0 ]; then
        echo "ERROR: VM ${VM_NAME} is currently locked - Stop your VM first"
	if [ "$f_newcreated" = "true" ]; then
	    cd ${BCK_TMPDIR} && rmdir ${BCK_FILENAME}
	fi
        exit 1
    fi
    echo "INFO: Enter password for ${USER} on ${HOSTNAME} if requested"
    rm -f md5sum.txt
    (cd "${VM_REPOSITORY}" && \
	sudo tar cvz --dereference ${VM_NAME}) |
	split -d --bytes=${BCK_CHUNKSIZE} --verbose - ${BCK_FILENAME}.tgz-
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR: remote tar returned $retval"
	exit 1
    fi
    echo "INFO: You may restart your VM now"

    echo "INFO: Calculating md5sum of ${BCK_FILENAME}"
    md5sum ${BCK_FILENAME}.tgz* >md5sum.txt || exit 1

    echo "INFO: Backup ${BCK_FILENAME} created successfully on ${BCK_TMPDIR}"
fi

num_splits=`ls ${BCK_FILENAME}.tgz-* | wc -l`

# set -x

#cat >myrestore.bat << EOF
#@echo off
#md5sum -c md5sum.txt
#cat *.tgz-* >xxx.tgz
#tar xvfz xxx.tgz
#EOF

sample_script=myrestore.sh
#
echo "#!/bin/sh"	>${sample_script}
cat >>${sample_script} << EOF
#
# Sample script to restore VM

#set -x

# Personalize as needed
#
EOF
echo "VM_BCKDIR=/source/Backup_VM/${BCK_FILENAME}"	>>${sample_script}
echo "VM_DESTDIR=/dest/My_VM/"				>>${sample_script}
cat >>${sample_script} << EOF

mkdir -p "\${VM_DESTDIR}" || exit 1
cd "\${VM_BCKDIR}" && md5sum -c md5sum.txt || exit 1
cd "\${VM_DESTDIR}" && cat "\${VM_BCKDIR}"/*.tgz-* | tar xvz

# === EOF ===
EOF
chmod 755 ${sample_script}


if [ "${OPT_EXPORT_TO_NAS}" = "true" ]; then
    echo "INFO: Copying tarball to ${NAS_SHARE}"
    #echo "INFO: Enter password for ${NAS_USER} on ${NAS_SHARE} if requested"

    CMDFILE=smb_commands.tmp
    echo >${CMDFILE} || exit 1

    echo "cd ${NAS_BACKUPDIR}/" | tr '/' '\\'	>>${CMDFILE}
    echo "dir"			>>${CMDFILE}
    echo ""				>>${CMDFILE}
    echo "mkdir ${BCK_FILENAME}"	>>${CMDFILE}
    echo "cd ${BCK_FILENAME}"	>>${CMDFILE}
    for file in ${BCK_FILENAME}.tgz* md5sum.txt ${sample_script}; do
        echo "put ${file}"		>>${CMDFILE}
    done
    echo "dir"			>>${CMDFILE}
    echo "quit" 			>>${CMDFILE}

    cat ${CMDFILE} | smbclient --user ${NAS_USER} --workgroup ${NAS_DOMAIN} \
    ${NAS_SHARE} ${NAS_PASSWORD} || exit 1

    # TODO rm -f ${CMDFILE}
fi

# TODO: rm -rf ${BCK_TMPDIR}

# === EOF ===
