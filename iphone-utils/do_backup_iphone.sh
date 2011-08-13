#!/bin/sh

# =============================================================================
# Project:	admin_scripts
#
# Purpose:	Backup filesystem of a Jailbroken iPhone
# =============================================================================

# -----------------------------------------------------------------------------
# Main program follows
# -----------------------------------------------------------------------------

set -x
set -e

PROGNAME="`basename $0`"
echo "INFO: ${PROGNAME} - v0.1"

if [ "${REMOTEUSER}" = "" ]; then
	REMOTEUSER="root"
	read -p "REMOTEUSER [${REMOTEUSER}]: " line
	[ "$line" != "" ] && REMOTEUSER=$line
fi

if [ "${REMOTEHOST}" = "" ]; then
	REMOTEHOST="172.20.10.2"
	read -p "REMOTEHOST [${REMOTEHOST}]: " line
	[ "$line" != "" ] && REMOTEHOST=$line
fi

if [ "${PARTS}" = "" ]; then
	PARTS="/"
	#PARTS=""
	#PARTS="${PARTS} /Developer"
	#PARTS="${PARTS} /Library"
	#PARTS="${PARTS} /System"
	PARTS="${PARTS} /private/etc"
	read -p "PARTS [${PARTS}]: " line
	[ "$line" != "" ] && PARTS=$line
fi

if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="${HOME}/BACKUP/Backup_devices"
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
    echo "DBG: GPG_PIPE=\"${GPG_PIPE}\""
else
    GPG_PIPE="cat"
fi

echo "INFO: Backing up filesystem from ${REMOTEHOST}"
echo TODO

for part in ${PARTS}; do

    echo "INFO: Dumping ${part} from ${REMOTEHOST}"

	FILES="${NOW}-bk-${REMOTEHOST}"
	FILES="${FILES}-`echo $part | tr '/' '_'`"
    if [ "${GPG_RECIPIENT}" != "NONE" ]; then
        FILES="${FILES}.tgz.gpg-split"
    else
        FILES="${FILES}.tgz-split"
    fi
    (ssh "${REMOTEUSER}@${REMOTEHOST}" \
		"tar -cvz -C ${part} ." \
	) | ${GPG_PIPE} | split -b 2048m -d - "${FILES}"
	# > "${NOW}-bk-${REMOTEHOST}.tgz"
	# | hexdump 
    retval=$?
   if [ $retval -ne 0 ]; then
	echo "ERROR: Dumping $part from $REMOTEHOST returned ${retval}";
	exit 1
   fi

#   echo "INFO: Creating sample script to restore repository"
#   samplescript="sample-restore-${repos}.sh"
#   (
#	echo "#!/bin/sh"
#	echo ""
#	echo "# Sample script to restore ${repos}"
#	echo "# http://svnbook.red-bean.com/en/1.5/svn.reposadmin.maint.html"
#	echo "#"
#	echo "# How to check-out working copy:"
#	echo "# TODO: svn checkout file:///path/${repos}"
#	echo ""
#	echo "# Configurable parameters"
#	echo "BACKUPDIR=\"\$(dirname \$0)\""
#	echo "NEWREPOS=\"new-${repos}\""
#	echo "FILES=${FILES}"
#	echo ""
#	echo "#set -x"
#	echo "set -e"
#	echo ""
#	echo "echo INFO: Decrypting configuration files"
#	if [ "${GPG_RECIPIENT}" != "NONE" ]; then
#		echo "cat \${BACKUPDIR}/dav_svn.authz.asc | gpg >dav_svn.authz"
#	fi
#	echo ""
#	echo "echo INFO: Creating empty repository"
#	echo "svnadmin create \${NEWREPOS}"
#	echo ""
#	echo "echo INFO: Loading dumpfile into new repository"
#	if [ "${GPG_RECIPIENT}" != "NONE" ]; then
#		echo "#cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc | hexdump -Cv"
#		echo "#cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc > dumpfile"
#		echo "cat \${BACKUPDIR}/\${FILES}* | gpg | gzip -dc | svnadmin load \${NEWREPOS}"
#	else
#		echo "#zcat \${BACKUPDIR}/\${FILES}* | hexdump -Cv"
#		echo "#zcat \${BACKUPDIR}/\${FILES}* > dumpfile"
#		echo "zcat \${BACKUPDIR}/\${FILES}* | svnadmin load \${NEWREPOS}"
#	fi
#	echo ""
#	echo "echo INFO: Done"
#	echo ""
#	echo "# === EOF ==="
#    ) >"${samplescript}"
#    # | gpg --encrypt --armor \
#    chmod 755 "${samplescript}"

done

echo "INFO: ${PROGNAME} completed"

# === EOF ===