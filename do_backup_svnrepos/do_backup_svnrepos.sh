#!/bin/sh
# =============================================================================
# Backup all SVN Repositories available on a Remote Host
# =============================================================================

if [ "${REMOTEUSER}" = "" ]; then
	REMOTEUSER="administrator"
fi
if [ "${REMOTEHOST}" = "" ]; then
	REMOTEHOST="lupin05.venaria.marelli.it"
fi
if [ "${REPOSITORIES}" = "" ]; then
	REPOSITORIES=""
	#REPOSITORIES="${REPOSITORIES} inno"
	#REPOSITORIES="${REPOSITORIES} inno.OLD"
	#REPOSITORIES="${REPOSITORIES} mmseti"
	#REPOSITORIES="${REPOSITORIES} osstbox"
	REPOSITORIES="${REPOSITORIES} lupin"
fi
if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="/BACKUP/Backup_svnrepos/"
fi

NOW="`date '+%Y%m%d-%H%M'`"
BACKUPDIR="${BK_BASEDIR}`date '+%Y%m%d'`-${REMOTEHOST}"

#set -x

# TODO: Understand error dumping mmseti:
#	...
#	* Dumped revision 4.
#	* Dumped revision 5.
#	svnadmin: Can't read length line in file '/opt/repos/mmseti/db/revs/6'
#

echo "INFO: $0 - v0.3"

mkdir -p $BACKUPDIR || exit 1
cd $BACKUPDIR || exit 1

# TODO: Backup /etc/apache2/dav_svn.{authz,passwd}
scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.authz" .
#scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.passwd" .

for repos in ${REPOSITORIES}; do
    echo "INFO: Dumping SVN repos $repos from $REMOTEHOST..."
    (ssh ${REMOTEUSER}@${REMOTEHOST} svnadmin dump /opt/svnrepos/$repos | gzip -c -9) \
	| split -b 2048m -d - ${NOW}-bk-$repos.svndump.gz-split
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR: Dumping repository $repos returned $retval";
	exit 1
    fi
done
echo "INFO: Dumping repositories to $BACKUPDIR completed"

# === EOF ===
