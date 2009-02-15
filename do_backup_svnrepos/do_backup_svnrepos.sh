#!/bin/sh
# =============================================================================
# Backup all SVN Repositories available on a Remote Host
# =============================================================================

NOW=`date '+%Y%m%d-%H%M'`
REMOTE=macario@inno05.venaria.marelli.it

REPOSITORIES=""
REPOSITORIES+=" inno"
REPOSITORIES+=" mmseti"
REPOSITORIES+=" osstbox"

#set -x

# TODO: Understand error dumping mmseti:
#	...
#	* Dumped revision 4.
#	* Dumped revision 5.
#	svnadmin: Can't read length line in file '/opt/repos/mmseti/db/revs/6'
#

for repos in ${REPOSITORIES}; do
    echo "INFO: Dumping SVN repos $repos..."
    (ssh ${REMOTE} svnadmin dump /opt/repos/$repos | gzip -c -9) \
	| split -b 1024m -d - ${NOW}-bk-$repos.svndump.gz-split
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "ERROR dumping repository $repos";
	exit 1
    fi
done
echo "INFO: Dumping repositories completed"

# === EOF ===
