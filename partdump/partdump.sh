#!/bin/sh

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Dump hard disk partitions
#
# Language:	GNU shell script
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
SSD_DEV=/dev/sdb
PARTITIONS="1 2 3 4"
MOUNTPOINT=/tmp/mount
OUTDIR=/home/gmacario/MOVEME/20090503-Russelville_SSD
LOGFILE=partdump.log

# End of configurable parameters

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

fdisk -l ${SSD_DEV} >$OUTDIR/fdisk.txt

for part in $PARTITIONS; do
    umount ${SSD_DEV}$part 2>/dev/null || true
done

dd if=$SSD_DEV | gzip -c -9 >$OUTDIR/raw_device.gz

for part in $PARTITIONS; do
    mkdir -p $MOUNTPOINT
    mount -o ro ${SSD_DEV}$part $MOUNTPOINT
    (cd $MOUNTPOINT && tar cz .) >$OUTDIR/part$part.tar.gz
    umount $MOUNTPOINT
done
echo "INFO: Dump completed at `date`"
}

runme2 2>&1 | tee $OUTDIR/$LOGFILE

# === EOF ===
