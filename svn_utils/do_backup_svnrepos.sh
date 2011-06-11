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

PROGNAME="`basename $0`"
echo "INFO: ${PROGNAME} - v0.3"

mkdir -p $BACKUPDIR || exit 1
cd $BACKUPDIR || exit 1

# TODO: Backup /etc/apache2/dav_svn.{authz,passwd}
scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.authz" .
#scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.passwd" .

for repos in ${REPOSITORIES}; do
    echo "INFO: Dumping SVN repos $repos from $REMOTEHOST..."
    (ssh ${REMOTEUSER}@${REMOTEHOST} \
	svnadmin dump /opt/svnrepos/${repos} \
	| gzip -c -9) \
	| split -b 2048m -d - ${NOW}-bk-${repos}.svndump.gz-split
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR: Dumping repository $repos returned ${retval}";
	exit 1
    fi

    echo "INFO: Creating sample script to restore SVN repos"
    samplescript="sample-restore-${repos}.sh"
    (
	echo "#!/bin/sh"
	echo "# Sample script to restore ${repos}"
	echo "# http://svnbook.red-bean.com/en/1.5/svn.reposadmin.maint.html"
	echo ""
	echo "NEWREPOS=new-${repos}"
	echo "FILES=${NOW}-bk-${repos}.svndump.gz-split*"
	echo ""
	echo "#set -x"
	echo ""
	echo "#zcat \${FILES} | hexdump -Cv"
	echo "#zcat \${FILES} > dumpfile"
	echo ""
	echo "svnadmin create \${NEWREPOS}"
	echo "zcat \${FILES} | svnadmin load \${NEWREPOS}"
	echo ""
	echo "# === EOF ==="
    ) >"${samplescript}"
    chmod 755 "${samplescript}"
done

echo "INFO: ${PROGNAME} completed"

# === EOF ===
