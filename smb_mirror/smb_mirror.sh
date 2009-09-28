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
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#       may be overridden by smb_mirror.conf (see comments above)

# Mount source directory before rsyncing (and unmount at the end)
OPT_MOUNT_SOURCEDIR=true

# Samba Share on NAS
#NAS_SHARE=//itven1nnas1.venaria.marelli.it/lupin
#NAS_SHARE=//itven1nnas1.venaria.marelli.it/smeg
NAS_SHARE=//multi.mmemea.marelliad.net/telematic_doc

# Active Directory credentials (domain/user/password) on NAS_SHARE
NAS_DOMAIN=mmemea
#NAS_USER=paolodoz
#NAS_PASSWORD=MyPassword

# Source Directory to mirror
NAS_SOURCEDIR=Projets/17_projetSMEG_A9
#NAS_SOURCEDIR=.

# Mount point of the remote source directory
MIRROR_SOURCEDIR=$HOME/source/SMEG_A9

# Destination directory for mirror
MIRROR_DESTDIR=$HOME/mirrors/SMEG_A9

# TEST - Use Venaria mirror (only for test, the folder is not updated...)
NAS_SHARE=//itven1nnas1.venaria.marelli.it/smeg
NAS_SOURCEDIR=.

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Program starts here
echo "INFO: $0 - v0.1"

#set -x
set -e

## Request parameters if not specified in the section above
if [ "${MIRROR_SOURCEDIR}" = "" ]; then
    read -p "Enter MIRROR_SOURCEDIR: " MIRROR_SOURCEDIR
fi
#BCK_FILENAME=`date +%Y%m%d`-${VM_NAME}
if [ "${OPT_MOUNT_SOURCEDIR}" = "true" ]; then
    if [ "${NAS_DOMAIN}" = "" ]; then
        read -p "Enter NAS_DOMAIN: " NAS_DOMAIN
    fi
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
fi

mkdir -p ${MIRROR_SOURCEDIR}
mkdir -p ${MIRROR_DESTDIR}

sudo mount -t cifs ${NAS_SHARE} ${MIRROR_SOURCEDIR} \
	-o user=${NAS_DOMAIN}/${NAS_USER} \
	-o password=${NAS_PASSWORD} \
	-o ro

set -x
rsync -avz ${MIRROR_SOURCEDIR}/ ${MIRROR_DESTDIR}

# if [ "${OPT_MOUNT_SOURCEDIR}" = "true" ]; then
# 	sudo umount ${MIRROR_SOURCEDIR}
# fi

# === EOF ===
