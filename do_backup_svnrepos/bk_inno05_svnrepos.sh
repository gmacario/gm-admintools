#!/bin/sh
# =============================================================================
# Backup all SVN Repositories available on a Remote Host
# =============================================================================

NOW=`date '+%Y%m%d-%H%M'`
REMOTE=macario@inno05.venaria.marelli.it

set -x

# TODO: Understand error dumping mmseti:
#	...
#	* Dumped revision 4.
#	* Dumped revision 5.
#	svnadmin: Can't read length line in file '/opt/repos/mmseti/db/revs/6'
#
(ssh ${REMOTE} svnadmin dump /opt/repos/inno)    | split -b 1024m -d - ${NOW}-bk-inno.svndump-split && \
#(ssh ${REMOTE} svnadmin dump /opt/repos/mmseti)  >${NOW}-bk-mmseti.svndump && \
(ssh ${REMOTE} svnadmin dump /opt/repos/osstbox) | split -b 1024m -d - ${NOW}-bk-osstbox.svndump-split && \
echo "Done"

# === EOF ===
