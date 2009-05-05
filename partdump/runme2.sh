#!/bin/sh

set -x -e

[ `whoami` != root ] && exit 1

SSD_DEV=/dev/sdb
PARTITIONS="1 2 3 4"
MOUNTPOINT=/tmp/mount

fdisk -l $SSD_DEV >fdisk.txt

for part in $PARTITIONS; do
    umount ${SSD_DEV}$part || true
done

dd if=$SSD_DEV | gzip -c -9 >raw_device.gz

for part in $PARTITIONS; do
    mkdir -p $MOUNTPOINT
    mount -o ro ${SSD_DEV}$part $MOUNTPOINT
    (cd $MOUNTPOINT && tar cz .) >part$part.tar.gz
    umount $MOUNTPOINT
done

# === EOF ===
