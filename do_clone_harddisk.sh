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

DEV_SOURCE=sda
DEV_DEST=sdb

# End of configurable parameters
# -----------------------------------------------------------------------------
# Sanity Checks

# TODO: Make sure DEV_SOURCE exists and is not mounted

# TODO: Make sure DEV_DEST exists and is not mounted

# TODO: Make sure DEV_DEST is empty

# TODO


# -----------------------------------------------------------------------------
# TRASH FOLLOWS

#SMBSHARE=//itven1nnas1.venaria.marelli.it/LUPIN
#MOUNTPOINT=/mnt/lupin
#MOUNT_OPTS=uid=${USER}
#MOUNT_OPTS+=,username=macario
#MOUNT_OPTS+=,workgroup=MMEMEA
#MOUNT_OPTS+=,password=VERYSECRET

#sudo mkdir -p ${MOUNTPOINT}
#sudo smbmount ${SMBSHARE} ${MOUNTPOINT} -o ${MOUNT_OPTS} && \
#echo ${SMBSHARE} mounted to ${MOUNTPOINT}

# === EOF ===
