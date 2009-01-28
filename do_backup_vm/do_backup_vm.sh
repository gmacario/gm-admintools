#!/bin/sh
# =============================================================================
# Project:	LUPIN
#
# Description:	Backup a VMware VM and copy to a remote directory on NAS
#
# Language:	Linux Shell Script
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable parameters

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
#VM_NAME=lupin07
#VM_NAME=Ubuntu804-WR_PFIjan19
VM_NAME=ltib-tarek

# The following options are still unused:
#NAS_MOUNTPOINT=/mnt/lupin
#NAS_RELEASEDIR=/Master_Disks/Build_VM
#NAS_CHECKFILE=${NAS_MOUNTPOINT}/this_is_itven1nnas1_lupin.txt

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# Those parameters should not usually be changed

BCK_FILENAME=`date +%Y%m%d`-${VM_NAME}
BCK_CHUNKSIZE=1024m
#BCK_CHUNKSIZE=4500m

# -----------------------------------------------------------------------------
# Main Program starts here
echo -e "$0 - v0.2\n"

#set -x

# Request parameters if not specified in the section above
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
if [ "${BCK_TMPDIR}" = "" ]; then
    read -p "Enter BCK_TMPDIR: " VM_NAME
fi
if [ "${VM_NAME}" = "" ]; then
    read -p "Enter VM_NAME: " VM_NAME
fi

## Make sure NAS_SHARE is mounted
#if [ ! -f ${NAS_CHECKFILE} ]; then
#    sudo mkdir -p ${NAS_MOUNTPOINT}
#    sudo smbmount ${NAS_SHARE} ${NAS_MOUNTPOINT} \ 
#        -o username="${NAS_USER}",password="${NAS_PASSWORD}",workgroup=${NAS_DOMAIN}
##    sudo mount -t smbfs ${NAS_SHARE} ${NAS_MOUNTPOINT} \ 
##        -o username="${NAS_USER}",password="${NAS_PASSWORD}",workgroup=${NAS_DOMAIN}
#
#fi
#if [ ! -f ${NAS_CHECKFILE} ]; then
#    echo Cannot access file ${NAS_CHECKFILE}
#    exit 1
#fi

# Sanity checks
if [ ! -d "${VM_REPOSITORY}/${VM_NAME}" ]; then
    echo ERROR: Cannot find VM "${VM_NAME}" under "${VM_REPOSITORY}"
    exit 1
fi

# Make sure you can write your temporary files...
mkdir -p ${BCK_TMPDIR}/${BCK_FILENAME}
if [ $? -gt 0 ]; then
    echo "ERROR: Cannot create directory under ${BCK_TMPDIR}"
    exit 1
fi

cd ${BCK_TMPDIR}/${BCK_FILENAME} || exit 1

if [ -e ${BCK_FILENAME}.tgz* ]; then
    echo "WARNING: skipping creation of ${BCK_FILENAME}"
else
    # Make sure that VM is stopped
    VM_ISLOCKED=`find "${VM_REPOSITORY}/${VM_NAME}" -name "*.lck" | wc -l`
    if [ ${VM_ISLOCKED} -gt 0 ]; then
        echo "ERROR: VM ${VM_NAME} is currently locked - Stop your VM first"
        exit 1
    fi
    echo "*** Enter password for ${USER} on ${HOSTNAME} if requested"
    (cd "${VM_REPOSITORY}" && \
	sudo tar cvz ${VM_NAME}) |
	split -d -b${BCK_CHUNKSIZE} - ${BCK_FILENAME}.tgz- || exit 1
    rm -f md5sum.txt
    echo "*** You may restart your VM now"
fi

echo "*** Calculating md5sum of ${BCK_FILENAME}"
md5sum ${BCK_FILENAME}.tgz* >md5sum.txt || exit 1

# set -x

#cat <<EOF
#@echo off
#md5sum -c md5sum.txt
#cat *.tgz-* >xxx.tgz
#tar xvfz xxx.tgz
#
#EOF >myrestore.bat

#cat <<EOF
##/bin/sh
#md5sum -c md5sum.txt || exit 1
#cat *.tgz-* >xxx.tgz
#tar xvfz xxx.tgz
#
#EOF >myrestore.sh
#chmod 755 myrestore.sh

echo "*** Copying tarball to ${NAS_SHARE}"
#echo "*** Enter password for ${NAS_USER} on ${NAS_SHARE} if requested"
echo "cd ${NAS_BACKUPDIR}/
mkdir ${BCK_FILENAME}
cd ${BCK_FILENAME}
put ${BCK_FILENAME}.tgz*
put md5sum.txt
put myrestore.bat
put myrestore.sh
dir
quit" \
| smbclient --user ${NAS_USER} --workgroup ${NAS_DOMAIN} \
${NAS_SHARE} ${NAS_PASSWORD} || exit 1

# TODO: rm -rf ${BCK_TMPDIR}

# === EOF ===
