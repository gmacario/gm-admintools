#!/bin/bash

# =============================================================================
# Project:	NBT
#
# Purpose:	Mount partition fron Magneti Marelli NAS
#
# Language:	GNU bash script
#
# Note:		Should configure username,etc.
#
# Copyright 2007,2008 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

SMBSHARE=//itven1nnas1.venaria.marelli.it/BMW_NBT
MOUNTPOINT=/mnt/bmw_nbt
MOUNT_OPTS=uid=${USER}
MOUNT_OPTS+=,username=macario
MOUNT_OPTS+=,workgroup=MMEMEA
#MOUNT_OPTS+=,password=VERYSECRET

set -x

sudo mkdir -p ${MOUNTPOINT}
sudo smbmount ${SMBSHARE} ${MOUNTPOINT} -o ${MOUNT_OPTS} && \
echo ${SMBSHARE} mounted to ${MOUNTPOINT}

# === EOF ===
