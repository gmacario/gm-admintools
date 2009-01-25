#!/bin/bash

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Clone hard disks
#
# Language:	GNU bash script
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
#
# Package Dependencies:
#	Required:	awk cp fdisk fileutils sh
#	Optional:	grub mbr mke2fs ntfsprogs
#
# TODO: Should install MBR, boot loaders, etc.
# 	install-mbr ${DEV_DEST}
# 	grub --install-partition=${DEV_DEST}
#
# TODO: Should handle option OPT_RESIZE_PARTITION
# =============================================================================

# Configurable Parameters
#
# Source device
DEV_SOURCE=/dev/sda
#
# Destination device (WARNING: WILL DESTROY CONTENTS!!!)
DEV_DEST=/dev/sdb


# Advanced options - USE AT YOUR OWN RISK!!!
#
# Do not do consistency checks on DEV_SOURCE vs. DEV_DEST disk geometry
OPT_NO_GEOMETRY_CHECK=true
#
# Do not complain if some partitions on DEV_SOURCE are mounted
OPT_IGNORE_SOURCE_MOUNTED=true
#
# Create Master Boot Record on DEV_DEST
#OPT_CREATE_DEST_MBR=true
#
# Create partitions on DEV_DEST with the same layout as DEV_SOURCE
#OPT_CREATE_DEST_PARTITIONS=true
#
# Format partitions on DEV_DEST (implicit if OPT_CREATE_DEST_PARTITIONS)
#OPT_FORMAT_DEST_PARTITIONS=true
#
# Quick format (Do not check for bad blocks, etc - faster but less reliable)
#OPT_FORMAT_QUICK=true
#
# Partition to be resized in case the disks have different capacity
#OPT_RESIZE_PARTITION=2

# End of configurable parameters

# -----------------------------------------------------------------------------
# Utility Functions

# Print a line break
print_linebreak()
{
    echo "-------------------------------------------------------------------------------"
}

# Make sure that device $1 is not mounted
safe_umount()
{
    #echo "DBG: safe_umount($1)"
    if [ `grep $1 /proc/mounts | wc -l` -gt 0 ]; then
    	echo "DBG: $1 was mounted - unmounting now"
        umount $1 
    fi
    return 0
}

# Recursively copy filesystem from $1 to $2
#	$1	mnt_source	(ex "/tmp/mnt/source")
#	$2	mnt_dest	(ex "/tmp/mnt/dest")
recursive_copy()
{
    #echo "DBG: recursive_copy($1, $2)"
    cd "$1" || return 1
    cp -ax . "$2" || return 2
    cd
    return 0
}

# Safe copy of filesystems
#	$1	part_source	(ex "/dev/sda2")
#	$2	part_dest	(ex "/dev/sdb2")
#	$3	fstype		(ex "ext3")
# 
# Should gracefully handle case of part_source already mounted
safe_copy_fs()
{
set -x

    echo "DBG: safe_copyfs($1, $2, $3)"

    mnt_source="/tmp/mnt/source"
    mnt_dest="/tmp/mnt/dest"

    f_source_mounted=`LANG=C mount | grep $1 | wc -l`
    if [ ${f_source_mounted} -gt 0 ]; then
	ln -sf `LANG=C mount | grep $1 | awk '// {print $3}'` ${mnt_source} || return 1
    else
	mkdir -p ${mnt_source} || return 1
        mount -t $3 -o ro $1 ${mnt_source} || return 1
    fi

    mkdir -p ${mnt_dest} || return 2
    mount -t $3 $2 ${mnt_dest} || return 2

    recursive_copy ${mnt_source} ${mnt_dest} || return 3
    df $1 $2

    umount ${mnt_dest} || return 2
    rmdir ${mnt_dest} || return 2

    if [ ${f_source_mounted} -gt 0 ]; then
        rm -f ${mnt_source} || return 1
    else
        umount ${mnt_source} || return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Main Program starts here

echo -e "$0 - v0.2\n"

# Sanity Checks

if [ ${USER} != root ]; then
    echo This script should be run as root
    exit 1
fi

echo "=== List of available disks on the system:"
LANG=C fdisk -l | grep "^Disk /"
echo ""

if [ "${DEV_SOURCE}" = "" ]; then
    echo Please configure DEV_SOURCE
    exit 1
fi
if [ "${DEV_DEST}" = "" ]; then
    echo Please configure DEV_DEST
    exit 1
fi

echo "=== SOURCE disk information (${DEV_SOURCE})"
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
    if [ "${OPT_IGNORE_SOURCE_MOUNTED}" != "true" ]; then
    	exit 1
    fi
fi


echo
#print_linebreak

echo "=== DEST disk information (${DEV_DEST})"
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

echo "WARNING: THIS WILL DESTROY ALL CONTENT OF ${DEV_DEST}"
echo -n "Do you really want to proceed (YES/no)? "
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
#echo "DBG: DEV_SOURCE heads: ${heads_source}"
#echo "DBG: DEV_SOURCE sectors/track: ${sectrk_source}"
#echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
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

OPT_CREATE_DEST_PARTITIONS=true

fi		# if [ "${OPT_CREATE_DEST_MBR} = "true" ]


# Make partitions on DEV_DEST as per DEV_SOURCE
if [ "${OPT_CREATE_DEST_PARTITIONS}" = "true" ]; then

echo "Deleting all partitions on ${DEV_DEST}..."
outcmd=`LANG=C fdisk -l ${DEV_DEST} | grep "^${DEV_DEST}"`
#echo "DBG: outcmd=${outcmd}"
numparts=`echo "${outcmd}" | wc -l`
fdiskcmd=`echo "${outcmd}" | awk -v dev=${DEV_SOURCE} -v numparts=${numparts} '
BEGIN	{
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
	}
//	{
	part_num=substr($1,length(dev)+1)
	part_bootable=($2 == "*")
	part_start=(part_bootable ? $3 : $2)
	part_end=(part_bootable ? $4 : $3)
	part_id=(part_bootable ? $6 : $5)
	part_system=(part_bootable ? substr($0,index($0,$7)) : substr($0,index($0,$6)))

	# TODO: Should adjust part_end if OPT_RESIZE_PARTITION

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



# Format partitions on ${DEV_DEST}
if [ "${OPT_FORMAT_DEST_PARTITIONS}" = "true" ]; then

echo "Formatting partitions on ${DEV_DEST}..."
outcmd=`LANG=C fdisk -l ${DEV_DEST} | grep "^${DEV_DEST}"`
#echo "DBG: outcmd=${outcmd}"
echo "${outcmd}" | awk -v dev=${DEV_DEST} -v f_quick="${OPT_FORMAT_QUICK}" '
BEGIN	{
	f_quick = (match(f_quick,"true") ? 1 : 0)
	#print "echo DBG: f_quick=" f_quick
	}
//	{
	part_num=substr($1,length(dev)+1)
	part_bootable=($2 == "*")
	part_id=(part_bootable ? $6 : $5)
	part_system=(part_bootable ? substr($0,index($0,$7)) : substr($0,index($0,$6)))

	# Build up shell commands
	if (part_id == 5) {
		# Extended: do nothing (will format logical partitions instead)
	} else if (part_id == 7) {
		# HPFS/NFTS
		printf("safe_umount %s\n", $1);
		printf("echo === %s: Formatting as NTFS filesystem\n", $1)
		printf("mkntfs %s %s\n", (f_quick ? "-q" : ""), $1);
		#printf("echo === %s: Writing zero - format NTFS under MS Windows\n", $1);
		#printf("dd if=/dev/zero of=%s bs=512 count=16\n". $1);
	} else if (part_id == 82) {
		# Linux swap
		printf("echo === %s: Formatting as Linux swap partition\n", $1);
		printf("mkswap %s %s\n", (f_quick ? "" : "-c"), $1);
	} else if (part_id == 83) {
		# Linux
		printf("safe_umount %s\n", $1);
		printf("echo === %s: Formatting as ext3 filesystem\n", $1);
		printf("mkfs %s -t ext3 %s\n", (f_quick ? "" : "-c"), $1);
	# } else if (part_id == ?) {
	#	# Windows FAT16/FAT32/VFAT
	#	# TODO
	} else {
		printf("echo ERROR: %s: Unable to format filesystem %s (%s)\n", $1, part_id, part_system);
	}
	next
	}
END	{
	}
' | while read cmdline; do
    #echo "DBG: cmdline=${cmdline}"
    ${cmdline}
    if [ $? -gt 0 ]; then
	echo "ERROR executing \"${cmdline}\""
  	exit 1
    fi
done
echo "Formatting ${DEV_DEST} partitions completed"

fi		# if [ "${OPT_FORMAT_DEST_PARTITIONS}" = "true" ]


# TODO: Should gracefully handle partitions from ${DEV_SOURCE} already mounted
#    if [ "${OPT_IGNORE_SOURCE_MOUNTED}" != "true" ]; then
#    	TODO
#    fi

echo "Copying all data partitions from ${DEV_SOURCE} to ${DEV_DEST}..."
outcmd=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^${DEV_SOURCE}"`
echo "${outcmd}" | awk -v dev_source=${DEV_SOURCE} -v dev_dest=${DEV_DEST} '
BEGIN	{
	}
//	{
	part_num=substr($1,length(dev_source)+1)
	part_bootable=($2 == "*")
	part_id=(part_bootable ? $6 : $5)
	part_system=(part_bootable ? substr($0,index($0,$7)) : substr($0,index($0,$6)))

	# Build up shell commands
	if ((part_id == 5) || (part_id == 82)) {
	    # case 5:	Extended
	    # case 82:	Linux swap
		#
		# Do nothing
	} else if ((part_id == 7) || (part_id == 83)) {
	    # case 7:	HPFS/NTFS
	    # case 83:	Linux
	    	if (part_id == 7) {
		    fstype = "ntfs"
	    	} else if (part_id == 83) {
		    fstype = "ext3"
	    	} else {
		    fstype = "UNKNOWN"
	    	}
		printf("echo === Copying %s filesystem from %s to %s\n", 
			fstype, 
			dev_source part_num,
			dev_dest part_num);
		#
		printf("safe_copy_fs %s %s %s\n",
			dev_source part_num,
			dev_dest part_num,
			fstype);
#		#
#		mnt_source = "/tmp/mnt/source"
#		mnt_dest = "/tmp/mnt/dest"
#		printf("mkdir -p %s\n", mnt_source);
#		printf("mkdir -p %s\n", mnt_dest);
#		printf("mount -t %s -o ro %s%s %s\n", fstype, dev_source, part_num, mnt_source);
#		printf("mount -t %s %s%s %s\n", fstype, dev_dest, part_num, mnt_dest);
#		#
#		printf("recursive_copy %s %s\n", mnt_source, mnt_dest);
#		printf("df %s %s\n", mnt_source, mnt_dest);
#		#printf("df %s%s %s%s\n", dev_source, part_num, dev_dest, part_num);
#		#
#		printf("umount %s\n", mnt_dest);
#		printf("umount %s\n", mnt_source);
#		printf("rmdir %s\n", mnt_source);
#		printf("rmdir %s\n", mnt_dest);
	} else {
		printf("echo ERROR: %s: Unable to copy filesystem %s (%s)\n", $1, part_id, part_system);
	}
	next
	}
END	{
	}
' | while read cmdline; do
    #echo "DBG: cmdline=${cmdline}"
    echo "+ ${cmdline}"
    ${cmdline}
    if [ $? -gt 0 ]; then
	echo "ERROR executing \"${cmdline}\""
  	exit 1
    fi
done

#echo "Copying data partitions from ${DEV_SOURCE} to ${DEV_DEST} completed"
exit 0

# -----------------------------------------------------------------------------

# === EOF ===
