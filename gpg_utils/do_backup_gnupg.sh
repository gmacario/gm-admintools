#!/bin/sh

# ---------------------------------------------------------------------------
# Configurable parameters
# ---------------------------------------------------------------------------

# NONE

#REMOTEUSER="macario"
#REMOTEHOST="itven1d0541.venaria.marelli.it"

BACKUPDIR="${HOME}/BACKUP/GnuPG"
#BACKUPDIR="/opt/BACKUP"

TODAY="`date '+%Y%m%d'`"

# ---------------------------------------------------------------------------
# Main Program
# ---------------------------------------------------------------------------

#set -x
set -e

PROGNAME=`basename $0`
echo "INFO: ${PROGNAME} - v0.2"

if [ $# -lt 1 ]; then
    echo "Usage: ${PROGNAME} remoteuser@remotehost"
    exit 1
fi

REMOTEUSER=`echo $1 | sed -e 's/\@.*$//'`
REMOTEHOST=`echo $1 | sed -e 's/^.*@//'`

#echo "DEBUG: REMOTEUSER=$REMOTEUSER"
#echo "DEBUG: REMOTEHOST=$REMOTEHOST"

echo "INFO: Backing up GnuPG keys ${REMOTEUSER}@${REMOTEHOST}"

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

echo "INFO: GnuPG keys backed up at ${BACKUPDIR}/${BK_FILE}"

# === EOF ===
