#!/bin/sh

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Dump hard disk partitions
#
# Language:	GNU shell script
#
# Copyright 2007-2011 Magneti Marelli Electronic Systems - All Rights Reserved
#
# TODO:
#	1.  Sanity checks on SSD_DEV
#	2.  Define PARTITIONS parsing the output of "fdisk -l"
# =============================================================================

# -----------------------------------------------------------------------------
# Configurable Parameters
# -----------------------------------------------------------------------------

SSD_DEV="/dev/sdb"
PARTITIONS="1 2 3 4"
MOUNTPOINT="/tmp/mount"
OUTDIR="/home/macario/BACKUP/Backup_devices/20110822-Kingston_16GB"
LOGFILE="partdump.log"

# End of configurable parameters

# -----------------------------------------------------------------------------
# Main program follows
# -----------------------------------------------------------------------------

#set -x
set -e

runme2()
{
if [ `whoami` != root ]; then
	echo "ERROR: This program must be run as root"
	exit 1
fi

echo "INFO: Dumping partitions of ${SSD_DEV} into ${OUTDIR}"
echo "INFO: Dump started at `date`"

mkdir -p "${OUTDIR}"

fdisk -l ${SSD_DEV} >"${OUTDIR}/fdisk.txt"

# Make sure that no partitions of SSD_DEV are currently mounted
for part in $PARTITIONS; do
    umount "${SSD_DEV}$part" 2>/dev/null || true
done

# Dump raw device first
dd if="${SSD_DEV}" | gzip -c -9 >"${OUTDIR}/raw_device.gz"

# Then dump each filesystem as a separate tarball
for part in ${PARTITIONS}; do
    mkdir -p "${MOUNTPOINT}"
    mount -o ro "${SSD_DEV}$part" "${MOUNTPOINT}"
    (cd "${MOUNTPOINT}" && tar cz .) >"${OUTDIR}/part${part}.tar.gz"
    umount "${MOUNTPOINT}"
done
echo "INFO: Dump completed at `date`"
}

runme2 2>&1 | tee "${OUTDIR}/${LOGFILE}"

# === EOF ===
