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

# Configurable Parameters

DEV_SOURCE=/dev/sda
DEV_DEST=/dev/sdb
#OPT_CREATE_DEST_MBR=true
#OPT_CREATE_DEST_PARTITIONS=true
#OPT_ADJUST_LAST_PARTITION=true

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
#echo "${outcmd} | grep "^Disk""
echo
# Make sure DEV_SOURCE exists and is not mounted
if [ `echo ${outcmd} | grep "^Disk ${DEV_SOURCE}:" | wc -l` -ne 1 ]; then
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
if [ `echo ${outcmd} | grep "^Disk ${DEV_DEST}:" | wc -l` -ne 1 ]; then
    echo "ERROR: Device ${DEV_DEST} does not exist"
    exit 1
fi
if [ `mount | grep ${DEV_DEST} | wc -l` -gt 0 ]; then
    echo "ERROR: Some partitions of ${DEV_DEST} are mounted"
    mount | grep ${DEV_DEST}
    exit 1
fi

# Make sure that DEV_SOURCE is not bigger than DEV_DEST
disksize_source=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^Disk ${DEV_SOURCE}:" | awk '// {print $5}'`
disksize_dest=`LANG=C fdisk -l ${DEV_DEST} | grep "^Disk ${DEV_DEST}:" | awk '// {print $5}'`
#echo "DBG: DEV_SOURCE ${disksize_source}"
#echo "DBG: DEV_DEST   ${disksize_dest}"
if [ "${disksize_source}" -gt "${disksize_dest}" ]; then
	echo "ERROR: Incompatible disk size: source:${disksize_source} dest:${disksize_dest}"
	exit 1
fi

# NO NO NO
#
## Make sure that source and dest have the same blocksize
#blksize_source=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^Units"`
#blksize_dest=`LANG=C fdisk -l ${DEV_DEST} | grep "^Units"`
##echo "DBG: DEV_SOURCE ${blksize_source}"
##echo "DBG: DEV_DEST   ${blksize_dest}"
#if [ "${blksize_source}" != "${blksize_dest}" ]; then
#	echo "ERROR: Incompatible block size: source:${blksize_source} dest:${blksize_dest}"
#	exit 1
#fi

# Verify that ${DEV_SOURCE} and ${DEV_DEST} disk geometries are compatible
geom_source=`LANG=C fdisk -l ${DEV_SOURCE} | grep "cylinders$"`
geom_dest=`LANG=C fdisk -l ${DEV_DEST} | grep "cylinders$"`
#echo "DBG: DEV_SOURCE ${geom_source}"
#echo "DBG: DEV_DEST   ${geom_dest}"
if [ "${geom_source}" != "${geom_dest}" ]; then
	echo "WARNING: Different source and dest geometries"
	echo "  ${DEV_SOURCE}: ${geom_source}"
	echo "  ${DEV_DEST}: ${geom_dest}"
	echo
fi
heads_source=`echo ${geom_source} | awk '// {print $1}'`
heads_dest=`echo ${geom_dest} | awk '// {print $1}'`
#echo "DBG: DEV_SOURCE heads: ${heads_source}"
#echo "DBG: DEV_DEST   heads: ${heads_dest}"
if [ "${heads_source}" != "${heads_dest}" ]; then
	echo "ERROR: Incompatible #heads: source:${heads_source} and dest:${heads_dest}"
	exit 1
fi
sectrk_source=`echo ${geom_source} | awk '// {print $3}'`
sectrk_dest=`echo ${geom_dest} | awk '// {print $3}'`
#echo "DBG: DEV_SOURCE sectors/track: ${sectrk_source}"
#echo "DBG: DEV_DEST   sectors/track: ${sectrk_dest}"
if [ "${sectrk_source}" != "${sectrk_dest}" ]; then
	echo "ERROR: Incompatible #sectors/track: source (${sectrk_source}) dest:${sectrk_dest}"
	exit 1
fi
cylinders_source=`echo ${geom_source} | awk '// {print $5}'`
cylinders_dest=`echo ${geom_dest} | awk '// {print $5}'`
#echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
#echo "DBG: DEV_DEST   cylinders: ${cylinders_dest}"
if [ "${cylinders_source}" -gt "${cylinders_dest}" ]; then
	echo "ERROR: Incompatible #cylinders: source:${cylinders_source} dest:${cylinders_dest}"
	exit 1
fi

# TODO: Is partition table size calculated correctly???
parttbl_size=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^Units"`
echo "DBG: parttbl_size=${parttbl_size}"

echo "WARNING: this procedure will destroy contents on ${DEV_DEST}"
echo -n "Do you want to proceed (YES/no)? "
read ok
if [ "${ok}" != "YES" ]; then
	echo "Aborted"
	exit 1
fi

# Sanity checks OK, go ahead...

set -x

#echo TODO
#exit 0

echo "Wiping partition table on ${DEV_DEST}..."
dd if=/dev/zero of=${DEV_DEST} bs=512 count=1024

# TODO: Verify partition layout on ${DEV_SOURCE}

# TODO: Create partitions on ${DEV_DEST}
#    + sdy1: (NTFS, WinXP C:) xx GB
#    + sdy2: (NTFS, WinXP D:) size specified or all remaining space

# Copy MBR
# TODO: How much should I copy to preserve all MBR???
dd if=${DEV_SOURCE} of=${DEV_DEST} bs=512 count=1

# TODO: Format partitions on ${DEV_DEST}

echo "Cloning disk from ${DEV_SOURCE} to ${DEV_DEST}, please wait..."

# TODO: Copy all data in source partitions
#  + Boot WinXP from C:
#  + (Optional) Dual-boot Linux on remaining space

echo TODO TODO TODO

echo Disk cloning complete.
exit 0

# -----------------------------------------------------------------------------

# === EOF ===
