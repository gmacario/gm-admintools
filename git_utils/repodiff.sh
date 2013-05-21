#!/bin/sh
# ===========================================================================
# Project:	gm-admintools
# Program:	repodiff
# Purpose:	Get the deltas between a base git repository and a tarball
# Synopsis:	./repodiff.sh
# Known Bugs and limitations
#     * Parameters are currently hardcoded inside the script
# ============================================================================

set -x

BASE_REPO=git://git.yoctoproject.org/meta-ivi
BASE_SHA1=3.0.3
NEW_TARBALL=../20130517-Renesas_R-Car_H1_meta-ivi/meta-ivi.tar.bz2

TMPDIR=./tmp
OUTFILE=deltas-${BASE_SHA1}.patch

mkdir -p ${TMPDIR}
rm -rf ${TMPDIR}/a ${TMPDIR}/b
mkdir ${TMPDIR}/a ${TMPDIR}/b
pushd ${TMPDIR}/a
git clone ${BASE_REPO}
pushd *
git checkout ${BASE_SHA1}
popd
popd
tar xvf ${NEW_TARBALL} -C ${TMPDIR}/b
# Remove git metadata to avoid spurious deltas
rm -rf ${TMPDIR}/[ab]/*/.git

(
cat << END
# DATE=`date`
# BASE_REPO=${BASE_REPO} (${BASE_SHA1})
# NEW_TARBALL=`md5sum ${NEW_TARBALL}`
#
END
pushd ${TMPDIR}
diff -Nur a b >repodiff.tmp
diffstat repodiff.tmp
cat repodiff.tmp
rm repodiff.tmp
popd
) > ${OUTFILE}

echo "INFO: Deltas saved to ${OUTFILE}"

# === EOF ===
