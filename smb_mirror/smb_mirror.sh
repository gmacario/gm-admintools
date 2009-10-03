#!/bin/sh
# =============================================================================
# Project:	LUPIN
#
# Description:	Mirror a remote directory (available from Samba)
#
# Language:	Linux Shell Script
#
# Usage example:
#       $ ./smb_mirror.sh
#
# Package Dependencies:
#       Required:       awk cp fileutils samba sh
#	Optional:	?
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
#
# TODO:
#	- Should handle case when MIRROR_SOURCEDIR is already mounted
# =============================================================================

# Default values for configurable parameters
#
# NOTE: The following configuration variables
#       may be overridden by smb_mirror.conf (see comments above)

# Name of mirrored project (will be a subdirectory under MIRROR_BASEDIR)
#MIRROR_PROJECT=SMEG_A9@multi

# Mount source directory before rsyncing (and unmount at the end)
OPT_MOUNT_SOURCEDIR=true

# Samba Share on NAS
#NAS_SHARE=//multi.mmemea.marelliad.net/telematic_doc

# Source Directory to mirror (under NAS_SHARE)
#NAS_SOURCEDIR=Projets/17_projetSMEG_A9

# Active Directory credentials (domain/user/password) on NAS_SHARE
NAS_DOMAIN=mmemea
#NAS_USER=myuser
#NAS_PASSWORD=MyPassword

# Mount point of the remote source directory
REMOTE_MOUNTPOINT=${HOME}/remote

# Destination directory for mirror
#MIRROR_BASEDIR=$HOME/mirrors
MIRROR_BASEDIR=/var/www/mirrors

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Mirror one project
#
# $1: Name of the project to be mirrored
do_mirror_smbproject()
{
    MIRROR_PROJECT=$1

    # Define NAS_SHARE, NAS_SOURCEDIR based on MIRROR_PROJECT
    if [ "${MIRROR_PROJECT}" = "" ]; then
        read -p "Enter MIRROR_PROJECT: " MIRROR_PROJECT
    fi
    if [ "${MIRROR_PROJECT}" = "architects@multi" ]; then
	NAS_SHARE=//multi.mmemea.marelliad.net/telematic_doc
	NAS_SOURCEDIR="architects"
    fi
    if [ "${MIRROR_PROJECT}" = "SMEG_A9@multi" ]; then
	NAS_SHARE=//multi.mmemea.marelliad.net/telematic_doc
	NAS_SOURCEDIR="Projets/17_projetSMEG_A9"
    fi
    if [ "${MIRROR_PROJECT}" = "SMEG_OpenPlus_B78@multi" ]; then
	NAS_SHARE=//multi.mmemea.marelliad.net/telematic_doc
	NAS_SOURCEDIR="Projets/20_projet SMEG OPEN+ B78"
    fi
    # Use Venaria mirror for SMEG_A9@multi
    # (only for initial syncup, the folder is not kept updated...)
    if [ "${MIRROR_PROJECT}" = "SMEG@itven1nnas1" ]; then
	NAS_SHARE=//itven1nnas1.venaria.marelli.it/smeg
	NAS_SOURCEDIR=.
    fi

    # Request parameters if still unknown
    if [ "${NAS_SHARE}" = "" ]; then
        read -p "Enter NAS_SHARE: " NAS_SHARE
    fi
    if [ "${NAS_SOURCEDIR}" = "" ]; then
        read -p "Enter NAS_SOURCEDIR: " NAS_SOURCEDIR
    fi

    MIRROR_DESTDIR=${MIRROR_BASEDIR}/${MIRROR_PROJECT}
    mkdir -p ${MIRROR_DESTDIR}

    if [ "${OPT_MOUNT_SOURCEDIR}" = "true" ]; then
    sudo mount -t cifs ${NAS_SHARE} ${REMOTE_MOUNTPOINT} \
	-o user=${NAS_DOMAIN}/${NAS_USER} \
	-o password=${NAS_PASSWORD} \
	-o ro
    fi

    #rsync -avz ${REMOTE_MOUNTPOINT}/${NAS_SOURCEDIR}/ ${MIRROR_DESTDIR}
    cmdline="rsync -avz \
	${REMOTE_MOUNTPOINT}/${NAS_SOURCEDIR}/ \
	${MIRROR_DESTDIR}"
    echo "INFO: Executing ${cmdline}"
    ${cmdline}

    if [ "${OPT_MOUNT_SOURCEDIR}" = "true" ]; then
	sudo umount ${REMOTE_MOUNTPOINT}
    fi
}

# -----------------------------------------------------------------------------
# Main Program starts here
echo "INFO: $0 - v0.3"

#set -x
set -e

## Request parameters if not specified in the section above
if [ "${NAS_USER}" = "" ]; then
    read -p "Enter NAS_USER: " NAS_USER
fi
if [ "${NAS_PASSWORD}" = "" ]; then
    echo -n "Enter NAS_PASSWORD: "
    stty -echo
    read NAS_PASSWORD
    echo
    stty echo
fi

export NAS_USER
export NAS_PASSWORD

do_mirror_smbproject "SMEG_A9@multi"
# do_mirror_smbproject "architects@multi"
# do_mirror_smbproject "SMEG_OpenPlus_B78"
##do_mirror_smbproject "SMEG@itven1nnas1"

# === EOF ===
