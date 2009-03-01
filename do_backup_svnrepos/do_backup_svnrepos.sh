#!/bin/sh
# =============================================================================
# Backup all SVN Repositories available on a Remote Host
# =============================================================================

NOW=`date '+%Y%m%d-%H%M'`

REMOTEUSER=macario
REMOTEHOST=inno05.venaria.marelli.it

REPOSITORIES=""
REPOSITORIES+=" inno"
REPOSITORIES+=" mmseti"
REPOSITORIES+=" osstbox"

BACKUPDIR=/backup/Backup_svnrepos/`date '+%Y%m%d'`-inno05

#set -x

# TODO: Understand error dumping mmseti:
#	...
#	* Dumped revision 4.
#	* Dumped revision 5.
#	svnadmin: Can't read length line in file '/opt/repos/mmseti/db/revs/6'
#

echo "INFO: $0 - v0.1"

mkdir -p $BACKUPDIR || exit 1
cd $BACKUPDIR || exit 1
for repos in ${REPOSITORIES}; do
    echo "INFO: Dumping SVN repos $repos from $REMOTEHOST..."
    (ssh ${REMOTEUSER}@${REMOTEHOST} svnadmin dump /opt/repos/$repos | gzip -c -9) \
	| split -b 2048m -d - ${NOW}-bk-$repos.svndump.gz-split
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR: Dumping repository $repos returned $retval";
	exit 1
    fi
done
echo "INFO: Dumping repositories to $BACKUPDIR completed"

# === EOF ===
