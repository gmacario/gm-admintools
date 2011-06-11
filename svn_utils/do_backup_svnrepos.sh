#!/bin/sh

# =============================================================================
# Backup all SVN Repositories available on a Remote Host
# =============================================================================

# -----------------------------------------------------------------------------
# Main program follows
# -----------------------------------------------------------------------------

#set -x

PROGNAME="`basename $0`"
echo "INFO: ${PROGNAME} - v0.3"

if [ "${REMOTEUSER}" = "" ]; then
	REMOTEUSER="administrator"
	echo -n "REMOTEUSER [${REMOTEUSER}]: "
	read REMOTEUSER
fi
if [ "${REMOTEHOST}" = "" ]; then
	REMOTEHOST="lupin05.venaria.marelli.it"
	echo -n "REMOTEHOST [${REMOTEHOST}]: "
	read REMOTEHOST
fi
if [ "${REPOSITORIES}" = "" ]; then
	REPOSITORIES=""
	#REPOSITORIES="${REPOSITORIES} entrynav"
	REPOSITORIES="${REPOSITORIES} lupin"
	#REPOSITORIES="${REPOSITORIES} pmo"
	echo -n "REPOSITORIES [${REPOSITORIES}]: "
	read REPOSITORIES
fi
if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="/BACKUP/Backup_svnrepos/"
	echo -n "BK_BASEDIR [${BK_BASEDIR}]: "
	read BK_BASEDIR
fi

TODAY="`date '+%Y%m%d'`"
NOW="`date '+%Y%m%d-%H%M'`"
BACKUPDIR="${BK_BASEDIR}/${TODAY}-${REMOTEHOST}"

mkdir -p ${BACKUPDIR} || exit 1
cd ${BACKUPDIR} || exit 1

echo "INFO: Backing up config files from ${REMOTEHOST}"
scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.authz" .
#scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.passwd" .

for repos in ${REPOSITORIES}; do
    echo "INFO: Dumping repository $repos from ${REMOTEHOST}"
    (ssh ${REMOTEUSER}@${REMOTEHOST} \
	svnadmin dump /opt/svnrepos/${repos} \
	| gzip -c -9) \
	| split -b 2048m -d - ${NOW}-bk-${repos}.svndump.gz-split
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR: Dumping repository $repos returned ${retval}";
	exit 1
    fi

    echo "INFO: Creating sample script to restore repository"
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
	echo "#gpg --decrypt xxx"
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
