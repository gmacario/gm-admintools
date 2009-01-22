#!/bin/bash

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Clone hard disks
#
# Language:	GNU bash script
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

#set -x

DEV_SOURCE=sda
DEV_DEST=sdb

# End of configurable parameters
# -----------------------------------------------------------------------------
# Sanity Checks

if [ ${USER} != root ]; then
    echo This script should be run as root
    exit 1
fi

sudo LANG=C fdisk -l | awk '
/^Disk \/dev/	{ print $0 }
'

# TODO: Make sure DEV_SOURCE exists and is not mounted
if [ `mount | grep ${DEV_SOURCE} | wc -l` -gt 0 ]; then
    echo Warning: Some partitions of /dev/${DEV_SOURCE} are mounted
    mount | grep ${DEV_SOURCE}
fi
if [ `mount | grep ${DEV_DEST} | wc -l` -gt 0 ]; then
    echo ERROR: Some partitions of /dev/${DEV_DEST} are mounted
    mount | grep ${DEV_DEST}
    exit 1
fi

# TODO: Make sure DEV_DEST exists and is not mounted

# TODO: Make sure DEV_DEST is empty


# Sanity checks OK, go ahead...
echo Cloning disk from ${DEV_SOURCE} to ${DEV_DEST}, please wait...

# TODO: Verify partition layout on sdx

# TODO: Create partitions on sdy
#    + sdy1: (NTFS, WinXP C:) xx GB
#    + sdy2: (NTFS, WinXP D:) size specified or all remaining space

# TODO: Copy MBR

# TODO: Copy all data in source partitions
#  + Boot WinXP from C:
#  + (Optional) Dual-boot Linux on remaining space

echo TODO TODO TODO

echo Disk cloning complete.
exit 0

# -----------------------------------------------------------------------------
# TRASH FOLLOWS

#SMBSHARE=//itven1nnas1.venaria.marelli.it/LUPIN
#MOUNTPOINT=/mnt/lupin
#MOUNT_OPTS=uid=${USER}
#MOUNT_OPTS+=,username=macario
#MOUNT_OPTS+=,workgroup=MMEMEA
#MOUNT_OPTS+=,password=VERYSECRET

#sudo mkdir -p ${MOUNTPOINT}
#sudo smbmount ${SMBSHARE} ${MOUNTPOINT} -o ${MOUNT_OPTS} && \
#echo ${SMBSHARE} mounted to ${MOUNTPOINT}

# === EOF ===
