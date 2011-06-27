#!/bin/sh

# Configurable parameters
REMOTEUSER="gmacario"
REMOTEHOST="itven1d0400.venaria.marelli.it"
#REMOTEUSER="macario"
#REMOTEHOST="itven1d0541.venaria.marelli.it"

BACKUPDIR="${HOME}/BACKUP/GnuPG"
#BACKUPDIR="/opt/BACKUP"

TODAY="`date '+%Y%m%d'`"

#set -x

mkdir -p "${BACKUPDIR}"
if [ "${REMOTEUSER}" != "" ]; then
    BK_FILE="${TODAY}-${REMOTEHOST}-${REMOTEUSER}-gnupg.zip"

    echo "INF: Backing up GPG keys of ${REMOTEUSER}@${REMOTEHOST}"
    ssh "${REMOTEUSER}@${REMOTEHOST}" \
	"zip -rp - .gnupg" > "${BACKUPDIR}/${BK_FILE}"
else
    HOSTNAME="`hostname`"
    BK_FILE="${TODAY}-${HOSTNAME}-${USER}-gnupg.zip"

    echo "INF: Backing up GPG keys of ${USER}@${HOSTNAME}"
    cd
    zip -rp "${BACKUPDIR}/${BK_FILE}" .gnupg
fi

echo "INF: GPG keys backed up at ${BACKUPDIR}/${BK_FILE}"

# === EOF ===
