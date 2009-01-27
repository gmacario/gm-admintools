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
# Usage example:
#	$ LANG=C time sudo ./clonedisk.sh
#
# The script attempts to fetch configuration options
# from the first file in the following list:
#	* ./clonedisk.conf
#	* ${HOME}/.clonedisk/clonedisk.conf
#	* /etc/clonedisk.conf
#
# Package Dependencies:
#	Required:	awk cp fdisk fileutils sh
#	Optional:	grub mbr mke2fs ntfsprogs
#
# TODO: Should attempt installation of MBR, boot loaders (grub, lilo), etc.
#
# TODO:	There are still a few subtle bugs with OPT_RESIZE_PARTITIONS
#	when source and dest disks have different geometries
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#	may be overridden by clonedisk.conf (see comments above)

# Source device
#DEV_SOURCE=/dev/sda
#
# Destination device (WARNING: WILL DESTROY CONTENTS!!!)
#DEV_DEST=/dev/sdb
#
# Make sure that the script is run on the proper host
# in order to avoid clobbering the wrong disks
#OPT_CHECK_HOSTNAME=myhostname


# Advanced options - USE AT YOUR OWN RISK!!!
#
# Do not do consistency checks on DEV_SOURCE vs. DEV_DEST disk geometry
#OPT_NO_GEOMETRY_CHECK=true
#
# Do not complain if some partitions on DEV_SOURCE are mounted
#OPT_IGNORE_SOURCE_MOUNTED=true
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
# If true, partitions extending to end of disk
# will be resized to the actual disk capacity
#OPT_RESIZE_PARTITIONS=true

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
    cp -ax . "$2" || return 4
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
    #echo "DBG: safe_copyfs($1, $2, $3)"
    echo "=== Copying $3 filesystem from $1 to $2"

    #set -x

    # Append "-<pid>" to make the filename unique
    mnt_tmpdir="/tmp/mnt"
    mnt_source="${mnt_tmpdir}/source-$$"
    mnt_dest="${mnt_tmpdir}/dest-$$"

    f_source_mounted=`LANG=C mount | grep $1 | wc -l`
    if [ ${f_source_mounted} -gt 0 ]; then
	ln -sf `LANG=C mount | grep $1 | awk '// {print $3}'` ${mnt_source} || return 1
    else
	mkdir -p ${mnt_source} || return 1
        mount -t $3 -o ro,force $1 ${mnt_source} || return 1
    fi

    mkdir -p ${mnt_dest} || return 2
    mount -t $3 $2 ${mnt_dest} || return 2

    # Do not return on errors, so we can keep on copying other partitions...
    recursive_copy ${mnt_source} ${mnt_dest} 	# || return 4
    df $1 $2

    umount ${mnt_dest} || return 2
    rmdir ${mnt_dest} || return 2

    if [ ${f_source_mounted} -gt 0 ]; then
        rm -f ${mnt_source} || return 1
    else
        umount ${mnt_source} || return 1
        rmdir ${mnt_source} || return 1
    fi

    return 0
}



# TODO TODO TODO

# Code adapted from LUPIN/code/trunk/wrlinux/scripts/flash_distro-3.0.sh

# Install GRUB 
#	$1	install_device	(ex "/dev/sdb")
#	$2	root_part	(ex "/dev/sdb2")
#	$3	root_fstype	(ex "ext3")
#
do_install_grub() {
    echo "=== Installing GRUB on ${2} for root_part=${1} (${3})..."

    if [ "" == `which grub-install` ]; then
	echo "- You have to install grub. Try with sudo apt-get install grub. Exiting."
	exit 1;
    fi

    set -x

    mnt_root="/tmp/mnt/root-$$"
    mkdir -p ${mnt_root} || return 1
    mount -t ${3} ${2} ${mnt_root} || return 1

    menu_lst=${mnt_root}/boot/grub/menu.lst
    device_map=${mnt_root}/boot/grub/device.map

    ##################
    # write menu.lst and device.map
    ###################
    #
    #echo "default 0" > ${menu_lst}
    #echo "timeout 0" >> ${menu_lst}
    #echo "hiddenmenu" >> ${menu_lst}
    #echo "title WRLinux" >> ${menu_lst}
    #echo "root (hd0,0)" >> ${menu_lst}
    ## change in the next line root=/dev/sda1 if trying to create an usb pen
    ##echo "kernel /boot/bzImage root=/dev/hda1 rw" >> ${menu_lst}
    #echo "kernel /boot/bzImage root=/dev/hda1 rw noapic quiet ide1=noprobe hdb=none lpj=1597020 ide0=ata66" >> ${menu_lst}
    #echo "savedefault" >> ${menu_lst}
    ###################
    
    # Preserve original device map
    if [ -f ${device_map} ]; then
	rm -f ${device_map}.orig
	mv ${device_map} ${device_map}.orig
    fi
    #echo "(hd0) ${2}" > ${device_map}

    if [ ! -f ${menu_lst} ]; then
	echo "ERROR: Cannot find file ${menu_lst}"
	return 1
    fi
    #if [ ! -f ${device_map} ]; then
    #	echo "ERROR: Cannot find file ${device_map}"
    #	return 1
    #fi

    # "--recheck" option will create device_map as currently seen on the host machine
    grub-install --recheck --root-directory=${mnt_root} ${1} # &> /dev/null

    # Restore original device map
    if [ -f ${device_map}.orig ]; then
	rm -f ${device_map}
	mv ${device_map}.orig ${device_map}
    fi

    umount ${mnt_root} || return 2
    rmdir ${mnt_root} || return 2
}


# -----------------------------------------------------------------------------
# Main Program starts here

echo -e "$0 - v0.2\n"

# Sanity Checks

if [ ${USER} != root ]; then
    echo "ERROR: This script should be run as root"
    exit 1
fi

# Try to source configuration from clonedisk.conf
#
conffile=""
if [ -e ./clonedisk.conf ]; then
    conffile=./clonedisk.conf
elif [ -e ${HOME}/.clonedisk/clonedisk.conf ]; then
    conffile=${HOME}/.clonedisk/clonedisk.conf
elif [ -e /etc/clonedisk.conf ]; then
    conffile=/etc/clonedisk.conf
else
    echo "WARNING: no conffile found, using defaults"
fi
if [ "${conffile}" != "" ]; then
    echo "== Reading configuration from file ${conffile}"
    source ${conffile} || exit 1
fi
echo ""


echo "=== List of available disks on the system:"
LANG=C fdisk -l | grep "^Disk /"
echo ""

if [ "${DEV_SOURCE}" = "" ]; then
    echo "Please configure DEV_SOURCE"
    exit 1
fi
if [ "${DEV_DEST}" = "" ]; then
    echo "Please configure DEV_DEST"
    exit 1
fi
if [ "${OPT_CHECK_HOSTNAME}" != "" ]; then
    if [ "${OPT_CHECK_HOSTNAME}" != "`hostname`" ]; then
	echo "ERROR: This script is supposed to run on ${OPT_CHECK_HOSTNAME} while this is `hostname`"
	exit 1
    fi
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

echo "WARNING: THIS WILL DESTROY ALL CONTENTS OF ${DEV_DEST}"
echo -n "Do you really want to proceed (YES/no)? "
read ok
if [ "${ok}" != "YES" ]; then
	echo "Aborted"
	exit 1
fi

# Sanity checks OK, go ahead...

#echo "TODO: Handle case OPT_INSTALL_GRUB"
#do_install_grub /dev/sdb /dev/sdb2 ext3
#exit 0;	# TODO


# -----------------------------------------------------------------------------
# Create MBR and Partition Table
#
if [ "${OPT_CREATE_DEST_MBR}" = "true" ]; then

echo "== (OPT_CREATE_DEST_MBR) ==> Recreating MBR on ${DEV_DEST}..."

echo "=== Wiping partition table on ${DEV_DEST}..."
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


# -----------------------------------------------------------------------------
# Make partitions on DEV_DEST as per DEV_SOURCE
#
if [ "${OPT_CREATE_DEST_PARTITIONS}" = "true" ]; then

echo "== (OPT_CREATE_DEST_PARTITIONS) ==> Cloning partitions on ${DEV_DEST} as per ${DEV_SOURCE}..."

echo "=== Deleting all partitions on ${DEV_DEST}..."
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


echo "=== Creating partitions on ${DEV_DEST} as per ${DEV_SOURCE}..."

# Implement partition resizing to the end of disk
#
if [ "${OPT_RESIZE_PARTITIONS}" = "true" ]; then
    # TODO: There may be unnoticed bugs if (OPT_NO_GEOMETRY_CHECK)
    cylinders_max=${cylinders_dest}
else
    cylinders_max=${cylinders_source}
fi
#echo "DBG: DEV_SOURCE cylinders: ${cylinders_source}"
#echo "DBG: DEV_DEST   cylinders: ${cylinders_dest}"
#echo "DBG: MAX        cylinders: ${cylinders_max}"

numparts=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^${DEV_DEST}" | wc -l`
#echo "DBG: numparts=${numparts}"

outcmd=`LANG=C fdisk -l ${DEV_SOURCE} | grep "^${DEV_SOURCE}"`
#echo "DBG: outcmd=${outcmd}"
fdiskcmd=`echo "${outcmd}" | awk -v dev=${DEV_SOURCE} \
	-v cylinders_source=${cylinders_source} \
	-v cylinders_max=${cylinders_max} \
	-v numparts=${numparts} '
BEGIN	{
	}
//	{
	part_num=substr($1,length(dev)+1)
	part_bootable=($2 == "*")
	part_start=(part_bootable ? $3 : $2)
	part_end=(part_bootable ? $4 : $3)
	part_id=(part_bootable ? $6 : $5)
	part_system=(part_bootable ? substr($0,index($0,$7)) : substr($0,index($0,$6)))

	# Adjust part_end if at last cylinder (See OPT_RESIZE_PARTITION above)
	if (part_end >= cylinders_source) {
		part_end = cylinders_max
	}

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

# Create MBR
echo "=== Installing MBR on ${DEV_DEST}..."
install-mbr ${DEV_DEST}

# Make sure you will format the partitions just created...
OPT_FORMAT_DEST_PARTITIONS=true

fi		# if [ "${OPT_CREATE_DEST_PARTITIONS}" = "true" ]


# -----------------------------------------------------------------------------
# Format partitions on ${DEV_DEST}
#
if [ "${OPT_FORMAT_DEST_PARTITIONS}" = "true" ]; then

echo "== (OPT_FORMAT_DEST_PARTITIONS) ==> Formatting partitions on ${DEV_DEST}..."
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


# -----------------------------------------------------------------------------
# Copy data partitions from DEV_SOURCE to DEV_DEST
#
echo "== Copying all data partitions from ${DEV_SOURCE} to ${DEV_DEST}..."
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
		printf("safe_copy_fs %s %s %s\n",
			dev_source part_num,
			dev_dest part_num,
			fstype);
	} else {
		printf("echo ERROR: %s: Unable to copy filesystem %s (%s)\n", $1, part_id, part_system);
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
#echo "Copying data partitions from ${DEV_SOURCE} to ${DEV_DEST} completed"

if [ "${OPT_INSTALL_GRUB}" == "true" ]; then
    echo "TODO: Handle case OPT_INSTALL_GRUB"
    # TODO: do_install_grub /dev/sdb /dev/sdb1 ext3
fi


# -----------------------------------------------------------------------------
exit 0

# === EOF ===
