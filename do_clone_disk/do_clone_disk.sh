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

DEV_SOURCE=/dev/sda
DEV_DEST=/dev/sdb

# End of configurable parameters
# -----------------------------------------------------------------------------

print_linebreak()
{
echo "-------------------------------------------------------------------------------"
}

# -----------------------------------------------------------------------------

echo -e "$0 - v0.1\n"
#echo '$Id:'

# Sanity Checks

if [ ${USER} != root ]; then
    echo This script should be run as root
    exit 1
fi

#LANG=C fdisk -l | awk '
#/^Disk \/dev/	{ print $0 }
#'

echo "*** This is the SOURCE disk ***"
outcmd=`LANG=C fdisk -l ${DEV_SOURCE}`
echo "${outcmd}"
echo
# Make sure DEV_SOURCE exists and is not mounted
if [ `echo ${outcmd} | grep "Disk ${DEV_SOURCE}:" | wc -l` -ne 1 ]; then
    echo "ERROR: Device ${DEV_SOURCE} does not exist"
    exit 1
fi
if [ `mount | grep ${DEV_SOURCE} | wc -l` -gt 0 ]; then
    echo "WARNING: Some partitions of ${DEV_SOURCE} are mounted"
    mount | grep ${DEV_SOURCE}
fi

echo
#print_linebreak

echo "*** This is the DEST disk ***"
outcmd=`LANG=C fdisk -l ${DEV_DEST}`
echo "${outcmd}"
echo
# Make sure DEV_DEST exists and is not mounted
if [ `echo ${outcmd} | grep "Disk ${DEV_DEST}:" | wc -l` -ne 1 ]; then
    echo "ERROR: Device ${DEV_DEST} does not exist"
    exit 1
fi
if [ `mount | grep ${DEV_DEST} | wc -l` -gt 0 ]; then
    echo "ERROR: Some partitions of ${DEV_DEST} are mounted"
    mount | grep ${DEV_DEST}
    exit 1
fi

# TODO: Make sure DEV_DEST is empty

echo "WARNING: this procedure will destroy contents on ${DEV_DEST}"
echo -n "Do you want to proceed (YES/no)? "
read ok
if [ "${ok}" != "YES" ]; then
	echo "Aborted"
	exit 1
fi

# Sanity checks OK, go ahead...
echo Cloning disk from ${DEV_SOURCE} to ${DEV_DEST}, please wait...

# TODO: Verify partition layout on ${DEV_SOURCE}

# TODO: Create partitions on ${DEV_DEST}
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

# === EOF ===
