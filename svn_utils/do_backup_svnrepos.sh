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
	REMOTEUSER="gmacario"
	#REMOTEUSER="administrator"
	echo -n "REMOTEUSER [${REMOTEUSER}]: "
	read line
	[ "$line" != "" ] && REMOTEUSER=$line
fi
if [ "${REMOTEHOST}" = "" ]; then
	REMOTEHOST="localhost"
	#REMOTEHOST="lupin05.venaria.marelli.it"
	echo -n "REMOTEHOST [${REMOTEHOST}]: "
	read line
	[ "$line" != "" ] && REMOTEHOST=$line
fi
if [ "${REPOSITORIES}" = "" ]; then
	REPOSITORIES=""
	REPOSITORIES="testrepos"
	#REPOSITORIES="${REPOSITORIES} entrynav"
	#REPOSITORIES="${REPOSITORIES} lupin"
	#REPOSITORIES="${REPOSITORIES} pmo"
	echo -n "REPOSITORIES [${REPOSITORIES}]: "
	read line
	[ "$line" != "" ] && REPOSITORIES=$line
fi
if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="${HOME}/BACKUP/Backup_svnrepos/"
	#BK_BASEDIR="/BACKUP/Backup_svnrepos/"
	echo -n "BK_BASEDIR [${BK_BASEDIR}]: "
	read line
	[ "$line" != "" ] && BK_BASEDIR=$line
fi
if [ "${GPG_RECIPIENT}" = "" ]; then
	GPG_RECIPIENT="NONE"
	#GPG_RECIPIENT="alberto.cerato"
	echo -n "GPG_RECIPIENT [${GPG_RECIPIENT}]: "
	read line
	[ "$line" != "" ] && GPG_RECIPIENT=$line
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

    if [ "${GPG_RECIPIENT}" != "NONE" ]; then
        GPG_PIPE="gpg --encrypt --recipient ${GPG_RECIPIENT} -"
        FILES="${NOW}-bk-${repos}.svndump.gz.gpg-split"
    else
        GPG_PIPE="cat -"
        FILES="${NOW}-bk-${repos}.svndump.gz-split"
    fi
    (ssh "${REMOTEUSER}@${REMOTEHOST}" \
	svnadmin dump "/opt/svnrepos/${repos}" \
	| gzip -c -9) \
	| ${GPG_PIPE} | split -b 2048m -d - "${FILES}"
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
	echo "FILES=${FILES}"
	echo ""
	echo "#set -x"
	echo ""
	echo ""
	echo "svnadmin create \${NEWREPOS}"
	if [ "${GPG_RECIPIENT}" != "NONE" ]; then
		echo "#cat \${FILES} | gpg | gzip -dc | hexdump -Cv"
		echo "#cat \${FILES} | gpg | gzip -dc > dumpfile"
		echo "cat \${FILES}* | gpg | gzip -dc | svnadmin load \${NEWREPOS}"
	else
		echo "#zcat \${FILES} | hexdump -Cv"
		echo "#zcat \${FILES} > dumpfile"
		echo "zcat \${FILES}* | svnadmin load \${NEWREPOS}"
	fi
	echo ""
	echo "# === EOF ==="
    ) >"${samplescript}"
    # | gpg --encrypt --armor \
    chmod 755 "${samplescript}"
done

echo "INFO: ${PROGNAME} completed"

# === EOF ===
