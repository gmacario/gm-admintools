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
#       Required:       rm
#       Optional:       ?
#
# Note:
#	This script MUST be run before distributing
#	a Virtual Machine outside the LUPIN core team
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# CUSTOMER should be chosen within KNOWN_CUSTOMERS (see below)
#CUSTOMER=clueless
CUSTOMER=GENIVI

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

KNOWN_CUSTOMERS=""
KNOWN_CUSTOMERS+="BMW "		# BMW (EntryNav,NBT)
KNOWN_CUSTOMERS+="GENIVI "	# GENIVI (members with access to BMWI-POSR)
KNOWN_CUSTOMERS+="LUPIN "	# LUPIN team
KNOWN_CUSTOMERS+="MMSE "	# Magneti Marelli (outside the LUPIN team)
KNOWN_CUSTOMERS+="PSA "		# Peugeot-Citroen (SMEG Customer)
KNOWN_CUSTOMERS+="TES "		# TES (Contractor for OpenGL to SMEG/Linux)

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
# Main Program starts here
#
echo "INFO: $0 - v0.1"

if [ "$CUSTOMER" = "" ]; then
	echo "ERROR: Should configure CUSTOMER within script"
	exit 1
fi

ok=1
#echo "DBG: KNOWN_CUSTOMERS=\"$KNOWN_CUSTOMERS\""
for cust in $KNOWN_CUSTOMERS; do
	#echo "DBG: cust=$cust";
	[ "$CUSTOMER" = "$cust" ] && ok=0
done
if [ $ok -eq 1 ]; then
	echo "ERROR: CUSTOMER=$CUSTOMER is not one of: $KNOWN_CUSTOMERS"
	exit 1
fi

echo "INFO: Censoring VM for CUSTOMER=$CUSTOMER"

# TODO TODO TODO
#set -x
#exit 1

#RMTREE=rm -rf
RMTREE="echo TODO: rm -rf"

if [ $CUSTOMER != LUPIN ]; then
	$RMTREE /opt/LUPIN/code/trunk/area_51 || exit 1
fi
if [ $CUSTOMER != BMW ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/build_BMW* || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != GENIVI -a $CUSTOMER != PSA ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/build_GENIVI* || exit 1
fi
if [ $CUSTOMER != PSA ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/build_PSA* || exit 1
fi
if [ $CUSTOMER != BMW ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/layers/cust_BMW* || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != GENIVI -a $CUSTOMER != PSA ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/layers/cust_GENIVI* || exit 1
fi
if [ $CUSTOMER != PSA ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/layers/cust_PSA* || exit 1
fi
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/layers/mmse_experimental* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != MMSE ]; then
	$RMTREE /opt/LUPIN/code/trunk/wrlinux/layers/mmse_proprietary* || exit 1
fi

echo "INFO: Virtual Machine censored for CUSTOMER=$CUSTOMER"
exit 0

# === EOF ===
