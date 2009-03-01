#!/bin/sh

# =============================================================================
# Project:      LUPIN
#
# Description:  Censore a VM before distributing outside the LUPIN team
#
# Language:     Linux Shell Script
#
# Usage example:
#       $ ./do_censore_vm.sh
#
# Package Dependencies:
#       Required:       awk cp fileutils samba sh
#       Optional:       ?
#
# Note:
#	This script MUST be run before distributing
#	a Virtual Machine outside the LUPIN core team
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# CUSTOMER should be chosen between one of those:
#	BMW		BMW (EntryNav,NBT)
#	GENIVI		GENIVI (members with access to BMWI-POSR)
#	LUPIN		LUPIN team
#	MMSE		Magneti Marelli (outside the LUPIN team)
#	PSA		Peugeot-Citroen (SMEG Customer)
#	TES		TES (Contractor for OpenGL to SMEG/Linux)
CUSTOMER=clueless

# -----------------------------------------------------------------------------
# The script must handle the following directories:
#
# /home/user01/
#   + .git		???
#   + .mozilla
#   + .subversion
#
# /opt/LUPIN/code/trunk/
#   + apps/
#   + area_51/
#   + misc/
#     + admin_scripts/
#   + mm_sw/
#   + wrlinux/
#     + build_{BMW,GENIVI,Intel,PSA,SAIC}
#     + layers/
#       + cust_{BMW,GENIVI,Intel,PSA,SAIC}
#       + mmse_experimental
#       + mmse_proprietary
#
# /opt/WindRiver/
#   + license

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Program starts here
#
echo "INFO: $0 - v0.1"
echo "INFO: Censoring VM for CUSTOMER=$CUSTOMER"

if [ "$CUSTOMER" == "" -or "$CUSTOMER" == "clueless" ]; then
	echo "ERROR: Should configure CUSTOMER within script"
	exit 1
fi

# TODO TODO TODO
set -x

if [ $CUSTOMER != LUPIN ]; then
	rm -rf /opt/LUPIN/code/trunk/area_51
fi
if [ $CUSTOMER != BMW ]; then
	rm -rf /opt/LUPIN/code/trunk/wrlinux/build_BMW*
fi

# === EOF ===
