#!/bin/sh

export SSD_DEV=/dev/sdb
export PARTITIONS="1 2 3 4"
export MOUNTPOINT=/tmp/mount
export OUTDIR=/home/gmacario/MOVEME/20090503-Russelville_SSD
export LOGFILE=partdump.log

#set -x
set -e

if [ `whoami` != root ]; then
	echo "ERROR: This program must be run as root"
	exit 1
fi

runme2()
{
fdisk -l ${SSD_DEV} >$OUTDIR/fdisk.txt

for part in $PARTITIONS; do
    umount ${SSD_DEV}$part || true
done

dd if=$SSD_DEV | gzip -c -9 >$OUTDIR/raw_device.gz

for part in $PARTITIONS; do
    mkdir -p $MOUNTPOINT
    mount -o ro ${SSD_DEV}$part $MOUNTPOINT
    (cd $MOUNTPOINT && tar cz .) >$OUTDIR/part$part.tar.gz
    umount $MOUNTPOINT
done
}

#sudo ./runme2.sh 2>&1 | tee $OUTDIR/$LOGFILE
runme2 2>&1 | tee $OUTDIR/$LOGFILE

# === EOF ===
