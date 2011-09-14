#!/bin/sh

# =============================================================================
# Project:	admin_scripts/device-utils
#
# Purpose:	Backup partitions of a USB Pendrive
#
# Requirements:
#	1.  Clonezilla (http://clonezilla.org/)
# =============================================================================

# -----------------------------------------------------------------------------
# Main program follows
# -----------------------------------------------------------------------------

#set -x
set -e

PROGNAME="`basename $0`"
echo "INFO: ${PROGNAME} - v0.1"

#if [ "${REMOTEUSER}" = "" ]; then
#	REMOTEUSER="root"
#	read -p "REMOTEUSER [${REMOTEUSER}]: " line
#	[ "$line" != "" ] && REMOTEUSER=$line
#fi

#if [ "${REMOTEHOST}" = "" ]; then
#	REMOTEHOST="iPod-Marelli"
#	read -p "REMOTEHOST [${REMOTEHOST}]: " line
#	[ "$line" != "" ] && REMOTEHOST=$line
#fi

#if [ "${PARTS}" = "" ]; then
#	# Example 1: Backup portion of filesystem
#	PARTS=""
#	#PARTS="${PARTS} /Applications"
#	#PARTS="${PARTS} /Developer"
#	#PARTS="${PARTS} /Library"
#	#PARTS="${PARTS} /System"
#	#PARTS="${PARTS} /User"
#	PARTS="${PARTS} /bin"
#	#PARTS="${PARTS} /boot"
#	PARTS="${PARTS} /dev"
#	PARTS="${PARTS} /etc"
#	#PARTS="${PARTS} /lib"
#	#PARTS="${PARTS} /mnt"
#	#PARTS="${PARTS} /private"
#	PARTS="${PARTS} /private/etc"
#	PARTS="${PARTS} /sbin"
#	PARTS="${PARTS} /tmp"
#	#PARTS="${PARTS} /usr"
#	#PARTS="${PARTS} /var"
#	#PARTS="${PARTS} /var/root"
#	#
#	# Example 2: Backup complete filesystem
#	PARTS="/"
#	#
#	read -p "PARTS [${PARTS}]: " line
#	[ "$line" != "" ] && PARTS=$line
#fi

if [ "${BK_BASEDIR}" = "" ]; then
	BK_BASEDIR="${HOME}/BACKUP/Backup_devices"
	read -p "BK_BASEDIR [${BK_BASEDIR}]: " line
	[ "$line" != "" ] && BK_BASEDIR=$line
fi

if [ "${GPG_RECIPIENT}" = "" ]; then
	GPG_RECIPIENT="NONE"
	#GPG_RECIPIENT="gianpaolo.macario; filippo.pagin"
	read -p "GPG_RECIPIENT [${GPG_RECIPIENT}]: " line
	[ "$line" != "" ] && GPG_RECIPIENT=$line
fi

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

TODAY="`date '+%Y%m%d'`"
NOW="`date '+%Y%m%d-%H%M'`"
BACKUPDIR="${BK_BASEDIR}/${TODAY}-${REMOTEHOST}"

mkdir -p "${BACKUPDIR}" || exit 1
cd "${BACKUPDIR}" || exit 1

echo "INFO: Creating sample script to restore filesystem"
samplescript="sample-restore-${REMOTEHOST}.sh"
(
    echo "#!/bin/sh"
    echo ""
    echo "# Sample script to restore ${REMOTEHOST} filesystem"
    echo "#"
    echo "# Configurable Parameters"
#    echo "BACKUPDIR=\"\$(dirname \$0)\""
#    echo "NEW_ROOTFS=\"newfs-${REMOTEHOST}\""
#    echo "PARTS=\"${PARTS}\""
    echo ""
    echo "#set -x"
    echo "set -e"
    echo ""
#    echo "for part in \${PARTS}; do"
#    echo "    f=\"\${BACKUPDIR}/${NOW}-bk-${REMOTEHOST}\""
#    echo "    f=\"\${f}-\`echo \${part} | tr '/' '_'\`\""
#    if [ "${GPG_RECIPIENT}" != "NONE" ]; then
#        echo "    f=\"\${f}.tgz.gpg-split\""
#		GPG_PIPE="| gpg -dc |"
#    else
#        echo "    f=\"\${f}.tgz-split\""
#		GPG_PIPE="|"
#    fi
#    echo "    mkdir -p \"\${NEW_ROOTFS}/\${part}\""
#    echo "    pushd \"\${NEW_ROOTFS}/\${part}\""
#    echo "    echo \"INFO: Untarring \${f}\""
#    echo "    #ls \${f}* | xargs cat ${GPG_PIPE} wc"
#    echo "    #ls \${f}* | xargs cat ${GPG_PIPE} tar tvz"
#    echo "    ls \${f}* | xargs cat ${GPG_PIPE} tar xvz"
#    echo "    popd"
#    echo "done"
#    echo ""	
    echo "echo \"INFO: Done\""
    echo ""
    echo "# === EOF ==="
) >"${samplescript}"
# | gpg --encrypt --armor
chmod 755 "${samplescript}" || true

#echo "INFO: Backing up filesystem from ${REMOTEHOST}"
#for part in ${PARTS}; do
#    echo "INFO: Dumping ${part} from ${REMOTEHOST}"
#	FILES="${NOW}-bk-${REMOTEHOST}"
#	FILES="${FILES}-`echo $part | tr '/' '_'`"
#    if [ "${GPG_RECIPIENT}" != "NONE" ]; then
#        FILES="${FILES}.tgz.gpg-split"
#    else
#        FILES="${FILES}.tgz-split"
#    fi
#    (ssh "${REMOTEUSER}@${REMOTEHOST}" \
#		"tar -cvz -C ${part} ." \
#	) | ${GPG_PIPE} | split -b 1024m -d - "${FILES}"
#	# > "${NOW}-bk-${REMOTEHOST}.tgz"
#	# | hexdump 
#    retval=$?
#    if [ $retval -ne 0 ]; then
#	    echo "ERROR: Dumping ${part} from ${REMOTEHOST} returned ${retval}";
#	exit 1
#   fi
#done

echo "INFO: ${PROGNAME} completed"

# === EOF ===
