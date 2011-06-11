#!/bin/sh

BACKUPDIR="${HOME}/BACKUP"
#BACKUPDIR="/opt/BACKUP"

TODAY="`date '+%Y%m%d'`"
HOSTNAME="`hostname`"
BK_FILE="${TODAY}-${HOSTNAME}-${USER}-gnupg.zip"

cd
zip -urp "${BACKUPDIR}/${BK_FILE}" .gnupg

# === EOF ===
