#!/bin/bash

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Mount partition fron Magneti Marelli NAS
#
# Language:	GNU bash script
#
# Note:		Should configure username,etc.
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable parameters

# NAS Share used to save backups
NAS_SHARE=//itven1nnas1.venaria.marelli.it/lupin
#
# Active Directory credentials (domain/user/password) on NAS_SHARE
NAS_DOMAIN=mmemea
#NAS_USER=paolodoz
#NAS_PASSWORD=MyPassword

MOUNTPOINT=${HOME}/mnt/lupin

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# Those parameters should not usually be changed

MOUNT_OPTS=uid=${USER}
MOUNT_OPTS+=,username=${NAS_USER}
MOUNT_OPTS+=,workgroup=${NAS_DOMAIN}
#MOUNT_OPTS+=,password=${NAS_PASSWORD}

#set -x

if [ ! `which smbmount` ]; then
    echo "ERROR: Please ask your administrator to install smbfs package"
    exit 1
fi

#if [ "${NAS_PASSWORD}" = "" ]; then
#    echo -n "Enter NAS_PASSWORD: "
#    stty -echo
#    read NAS_PASSWORD
#    echo
#    stty echo
#fi

#echo "== Enter password for ${USER} on ${HOSTNAME} if requested"
mkdir -p ${MOUNTPOINT} || exit 1

echo "== Enter password for ${NAS_USER} on ${NAS_SHARE} if requested"
smbmount ${NAS_SHARE} ${MOUNTPOINT} -o ${MOUNT_OPTS} || exit 1
echo ${NAS_SHARE} mounted to ${MOUNTPOINT}

# === EOF ===
