#!/bin/sh

# =============================================================================
# Project:	admin_scripts
#
# Purpose:	Backup all SVN Repositories available on a Remote Host
# =============================================================================

# -----------------------------------------------------------------------------
# Main program follows
# -----------------------------------------------------------------------------

#set -x
set -e

PROGNAME="`basename $0`"
echo "INFO: ${PROGNAME} - v0.4"

if [ "${REMOTEUSER}" = "" ]; then
	REMOTEUSER="NONE"
	#REMOTEUSER="administrator"
	read -p "REMOTEUSER [${REMOTEUSER}]: " line
	[ "$line" != "" ] && REMOTEUSER=$line
fi
if [ "${REMOTEHOST}" = "" ]; then
	REMOTEHOST="NONE"
	#REMOTEHOST="localhost"
	read -p "REMOTEHOST [${REMOTEHOST}]: " line
	[ "$line" != "" ] && REMOTEHOST=$line
fi
if [ "${REPO_BASEDIR}" = "" ]; then
	REPO_BASEDIR="/opt/svnrepos"
	#REPO_BASEDIR="/cygdrive/d/opt"
	read -p "REPO_BASEDIR [${REPO_BASEDIR}]: " line
	[ "$line" != "" ] && REPO_BASEDIR=$line
fi
if [ "${REPOSITORIES}" = "" ]; then
	REPOSITORIES=""
	REPOSITORIES="testrepos"
	read -p "REPOSITORIES [${REPOSITORIES}]: " line
	[ "$line" != "" ] && REPOSITORIES=$line
fi
if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="${HOME}/BACKUP/Backup_svnrepos"
	#BK_BASEDIR="/BACKUP/Backup_svnrepos"
	read -p "BK_BASEDIR [${BK_BASEDIR}]: " line
	[ "$line" != "" ] && BK_BASEDIR=$line
fi
if [ "${GPG_RECIPIENT}" = "" ]; then
	GPG_RECIPIENT="NONE"
	#GPG_RECIPIENT="alberto.cerato; gianpaolo.macario"
	read -p "GPG_RECIPIENT [${GPG_RECIPIENT}]: " line
	[ "$line" != "" ] && GPG_RECIPIENT=$line
fi

TODAY="`date '+%Y%m%d'`"
NOW="`date '+%Y%m%d-%H%M'`"
BACKUPDIR="${BK_BASEDIR}/${TODAY}-${REMOTEHOST}"

mkdir -p ${BACKUPDIR} || exit 1
cd ${BACKUPDIR} || exit 1

if [ "${GPG_RECIPIENT}" != "NONE" ]; then
    GPG_PIPE="$(
        echo -n "gpg --encrypt --batch"
        echo "${GPG_RECIPIENT}" | tr ';' '\n' | while read entry; do 
	    echo -n " --group all=${entry}"
        done
        echo -n " --recipient all"
    )"
else
    GPG_PIPE="cat"
fi
#echo "DBG: GPG_PIPE=\"${GPG_PIPE}\""

if [ "${REMOTEHOST}" != "NONE" ]; then
  echo "INFO: Backing up config files from ${REMOTEHOST}"
  if [ "${GPG_RECIPIENT}" != "NONE" ]; then
    ssh "${REMOTEUSER}@${REMOTEHOST}" \
	"cat /etc/apache2/dav_svn.authz" \
	| ${GPG_PIPE} --armor >dav_svn.authz.asc
    # TODO: /etc/apache2/dav_svn.passwd
  else
    scp "${REMOTEUSER}@${REMOTEHOST}:/etc/apache2/dav_svn.authz" .
    # TODO: /etc/apache2/dav_svn.passwd
  fi
fi

echo "INFO: Dumping repositories..."
for repos in ${REPOSITORIES}; do
    if [ "${GPG_RECIPIENT}" != "NONE" ]; then
        FILES="${NOW}-bk-${repos}.svndump.gz.gpg-split"
    else
        FILES="${NOW}-bk-${repos}.svndump.gz-split"
    fi

    if [ "${REMOTEHOST}" != "NONE" ]; then
        echo "INFO: Dumping repository $repos from ${REMOTEHOST}"
        (ssh "${REMOTEUSER}@${REMOTEHOST}" \
	        svnadmin dump "${REPO_BASEDIR}/${repos}" \
	        | gzip -c -9) \
	        | ${GPG_PIPE} | split -b 2048m -d - "${FILES}"
        retval=$?
	else
        echo "INFO: Dumping local repository $repos"
        (svnadmin dump "${REPO_BASEDIR}/${repos}" \
	        | gzip -c -9) \
	        | ${GPG_PIPE} | split -b 2048m -d - "${FILES}"
        retval=$?
	fi
    if [ $retval -ne 0 ]; then
        echo "ERROR: Dumping repository $repos returned ${retval}";
  	    exit 1
	fi

    echo "INFO: Creating sample script to restore repository"
    samplescript="sample-restore-${repos}.sh"
    (
	echo "#!/bin/sh"
	echo ""
	echo "# Sample script to restore ${repos}"
	echo "# http://svnbook.red-bean.com/en/1.5/svn.reposadmin.maint.html"
	echo "#"
	echo "# How to check-out working copy:"
	echo "# TODO: svn checkout file:///path/${repos}"
	echo ""
	echo "# Configurable parameters"
	echo "BACKUPDIR=\"\$(dirname \$0)\""
	echo "NEWREPOS=\"new-${repos}\""
	echo "FILES=${FILES}"
	echo ""
	echo "#set -x"
	echo "set -e"
	echo ""
	echo "echo INFO: Decrypting configuration files"
	if [ "${GPG_RECIPIENT}" != "NONE" ]; then
		echo "cat \${BACKUPDIR}/dav_svn.authz.asc | gpg >dav_svn.authz"
	fi
	echo ""
	echo "echo INFO: Creating empty repository"
	echo "svnadmin create \${NEWREPOS}"
	echo ""
	echo "echo INFO: Loading dumpfile into new repository"
	if [ "${GPG_RECIPIENT}" != "NONE" ]; then
		echo "#cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc | hexdump -Cv"
		echo "#cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc > dumpfile"
		echo "cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc | svnadmin load \${NEWREPOS}"
	else
		echo "#zcat \${BACKUPDIR}/\${FILES}* | hexdump -Cv"
		echo "#zcat \${BACKUPDIR}/\${FILES}* > dumpfile"
		echo "zcat \${BACKUPDIR}/\${FILES}* | svnadmin load \${NEWREPOS}"
	fi
	echo ""
	echo "echo INFO: Done"
	echo ""
	echo "# === EOF ==="
    ) >"${samplescript}"
    # | gpg --encrypt --armor \
    chmod 755 "${samplescript}"
done

echo "INFO: ${PROGNAME} completed"

# === EOF ===
