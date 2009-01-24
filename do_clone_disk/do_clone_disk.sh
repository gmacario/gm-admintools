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
#
# Source device
DEV_SOURCE=/dev/sda
#
# Destination device (WARNING: WILL DESTROY CONTENTS!!!)
DEV_DEST=/dev/sdc


# Advanced options - USE AT YOUR OWN RISK!!!
#
# Do no consistency checks on DEV_SOURCE vs. DEV_DEST disk geometry
OPT_NO_GEOMETRY_CHECK=true
#
# Create Master Boot Record on DEV_DEST
#OPT_CREATE_DEST_MBR=true
#
# Create partitions on DEV_DEST (same layout as DEV_SOURCE)
OPT_CREATE_DEST_PARTITIONS=true
#
# Format partitions on DEV_DEST (implicit if OPT_CREATE_DEST_PARTITIONS)
#OPT_FORMAT_DEST_PARTITIONS=true
#
# Specify the number of the partition to resize in case the two disks have different capacity
#OPT_RESIZE_PARTITION=2

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

echo "*** List of available disks on the system:"
LANG=C fdisk -l | grep "^Disk /"
echo

echo "*** SOURCE disk information (${DEV_SOURCE}) ***"
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

echo "*** DEST disk information (${DEV_DEST}) ***"
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

# Verify that ${DEV_SOURCE} and ${DEV_DEST} disk geometries are compatible
geom_source=`LANG=C fdisk -l ${DEV_SOURCE} | grep "cylinders$"`
geom_dest=`LANG=C fdisk -l ${DEV_DEST} | grep "cylinders$"`
#echo "DBG: DEV_SOURCE ${geom_source}"
#echo "DBG: DEV_DEST   ${geom_dest}"
if [ "${geom_source}" != "${geom_dest}" ]; then
	echo "WARNING: Different geometries on source and dest devices:"
	echo "  ${DEV_SOURCE}: ${geom_source}"
	echo "  ${DEV_DEST}: ${geom_dest}"
	echo
fi
heads_source=`echo ${geom_source} | awk '// {print $1}'`
heads_dest=`echo ${geom_dest} | awk '// {print $1}'`
#echo "DBG: DEV_SOURCE heads: ${heads_source}"
#echo "DBG: DEV_DEST   heads: ${heads_dest}"
if [ "${heads_source}" != "${heads_dest}" ]; then
	echo "ERROR: Incompatible #heads: source:${heads_source} dest:${heads_dest}"
	[ "${OPT_NO_GEOMETRY_CHECK}" == "true" ] || exit 1
fi
sectrk_source=`echo ${geom_source} | awk '// {print $3}'`
sectrk_dest=`echo ${geom_dest} | awk '// {print $3}'`
#echo "DBG: DEV_SOURCE sectors/track: ${sectrk_source}"
#echo "DBG: DEV_DEST   sectors/track: ${sectrk_dest}"
if [ "${sectrk_source}" != "${sectrk_dest}" ]; then
	echo "ERROR: Incompatible #sectors/track: source:${sectrk_source} dest:${sectrk_dest}"
	[ "${OPT_NO_GEOMETRY_CHECK}" == "true" ] || exit 1
fi
cylinders_source=`echo ${geom_source} | awk '// {print $5}'`
cylinders_dest=`echo ${geom_dest} | awk '// {print $5}'`
#echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
#echo "DBG: DEV_DEST   cylinders: ${cylinders_dest}"
if [ "${cylinders_source}" -gt "${cylinders_dest}" ]; then
	echo "ERROR: Incompatible #cylinders: source:${cylinders_source} dest:${cylinders_dest}"
	exit 1
fi

# TODO: Is partition table size calculated correctly??? (here is calculated as one cylinder)
parttbl_size=`LANG=C fdisk -l ${DEV_SOURCE} | awk '/^Units/ {print $9}'`
#echo "DBG: parttbl_size=${parttbl_size}"

echo "WARNING: THIS WILL DESTROY CONTENTS ON ${DEV_DEST}"
echo -n "Do you want to proceed (YES/no)? "
read ok
if [ "${ok}" != "YES" ]; then
	echo "Aborted"
	exit 1
fi

# Sanity checks OK, go ahead...

if [ "${OPT_CREATE_DEST_MBR}" = "true" ]; then
echo "Wiping partition table on ${DEV_DEST}..."
dd if=/dev/zero of=${DEV_DEST} bs=${parttbl_size} count=1 >&/dev/null

# Adjust disk geometry on ${DEV_DEST} to resemble ${DEV_SOURCE}
echo "DBG: DEV_SOURCE heads: ${heads_source}"
echo "DBG: DEV_SOURCE sectors/track: ${sectrk_source}"
echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
echo "
x
h
${heads_source}
s
${sectrk_source}
r
p
w
" | LANG=C fdisk ${DEV_DEST} >&/dev/null

# Display what happened in the end...
LANG=C fdisk -l ${DEV_DEST}

# TODO: Why do not heads,sectrk change?

# Copy MBR (boot sector???)
# TODO: How much should I copy to preserve all MBR???
#dd if=${DEV_SOURCE} of=${DEV_DEST} bs=512 count=1

fi		# if [ "${OPT_CREATE_DEST_MBR} = "true" ]


# TODO: Verify partition layout on ${DEV_SOURCE}
#    + sdy1: (NTFS, WinXP C:) xx GB
#    + sdy2: (NTFS, WinXP D:) size specified or all remaining space


if [ "${OPT_CREATE_DEST_PARTITIONS}" = "true" ]; then

echo "Deleting all partitions on ${DEV_DEST}..."
outcmd=`LANG=C fdisk -l ${DEV_DEST} | grep "^${DEV_DEST}"`
#echo "DBG: outcmd=${outcmd}"
numparts=`echo "${outcmd}" | wc -l`
fdiskcmd=`echo "${outcmd}" | awk -v dev=${DEV_SOURCE} -v numparts=${numparts} '
BEGIN	{
	print ""
	}
//	{
	part_num=substr($1,length(dev)+1)
	#print "DBG: part_num=" part_num
	#print ""

	# Build up fdisk commands
	print "d"
	if (numparts > 1) print part_num

	numparts--
	skip
	}
END	{
	print "p"
	print "w"
	}
'`
#echo "DBG: fdiskcmd=${fdiskcmd}"
echo ${fdiskcmd} | tr " " "\n" | LANG=C fdisk ${DEV_DEST} >&/dev/null

echo "Creating partitions on ${DEV_DEST} as per ${DEV_SOURCE}..."
outcmd=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^${DEV_SOURCE}"`
#echo "DBG: outcmd=${outcmd}"
fdiskcmd=`echo "${outcmd}" | awk -v dev=${DEV_SOURCE} -v numparts=0 '
BEGIN	{
	print ""
	}
//	{
	part_num=substr($1,length(dev)+1)
	#print "DBG: part_num=" part_num
	part_bootable=($2 == "*")
	#print "DBG: part_bootable=" part_bootable
	part_start=(part_bootable ? $3 : $2)
	#print "DBG: part_start=" part_start
	part_end=(part_bootable ? $4 : $3)
	#print "DBG: part_end=" part_end
	part_id=(part_bootable ? $6 : $5)
	#print "DBG: part_id=" part_id
	part_system=(part_bootable ? $7 : $6)
	#print "DBG: part_system=" part_system
	print ""

	# TODO: Should extend part_end if OPT_XXX

	# Build up fdisk commands
	print "n"
	if (part_num >=1 && part_num <= 4) {
		if (part_system != "Extended") {
			print "p"
		} else {
			print "e"
		}
		print part_num
	} else {
		print "l"
	}
	print part_start
	print part_end

	if (part_system != "Extended") {
		print "t"
		if (numparts > 0) {
			print part_num
		}
		print part_id
	}

	if (part_bootable) {
		print "a"
		print part_num
	}
	print ""

	numparts++
	skip
	}
END	{
	print "p"
	print "w"
	}
'`
#echo "DBG: DEV_SOURCE heads: ${heads_source}"
#echo "DBG: DEV_SOURCE sectors/track: ${sectrk_source}"
#echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
#echo "DBG: fdiskcmd=${fdiskcmd}"
echo "
x
h
${heads_source}
s
${sectrk_source}
r
" ${fdiskcmd} | tr " " "\n" | LANG=C fdisk ${DEV_DEST} >&/dev/null

# Display what happened in the end...
LANG=C fdisk -l ${DEV_DEST}

# Make sure you will format the partitions just created...
OPT_FORMAT_DEST_PARTITIONS=true

fi		# if [ "${OPT_CREATE_DEST_PARTITIONS}" = "true" ]



# TODO: Format partitions on ${DEV_DEST}
if [ "${OPT_FORMAT_DEST_PARTITIONS}" = "true" ]; then

echo "Formatting partitions on ${DEV_DEST}..."

# ...

fi		# if [ "${OPT_FORMAT_DEST_PARTITIONS}" = "true" ]


set -x
echo TODO
exit 0




echo "Cloning disk from ${DEV_SOURCE} to ${DEV_DEST}, please wait..."

# TODO: Copy all data in source partitions
#  + Boot WinXP from C:
#  + (Optional) Dual-boot Linux on remaining space

echo TODO TODO TODO

echo Disk cloning complete.
exit 0

# -----------------------------------------------------------------------------

# === EOF ===
