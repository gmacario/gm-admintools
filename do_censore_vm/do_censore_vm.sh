#!/bin/sh

# =============================================================================
# Project:      LUPIN
#
# Description:  Censore a VM before distributing outside the LUPIN team
#
# Language:     Linux Shell Script
#
# Usage examples:
#       $ ./do_censore_vm.sh
#       $ CUSTOMER=clueless ./do_censore_vm.sh
#       $ CUSTOMER=GENIVI OPT_REMOVE=true ./do_censore_vm.sh
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

# If set to true, do actually remove directory
#OPT_REMOVE=true

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

KNOWN_CUSTOMERS=""
KNOWN_CUSTOMERS+="BMW "		# BMW (EntryNav,NBT)
KNOWN_CUSTOMERS+="GENIVI "	# GENIVI (members with access to BMWI-POSR)
KNOWN_CUSTOMERS+="LUPIN "	# LUPIN team
KNOWN_CUSTOMERS+="MMSE "	# Magneti Marelli (outside the LUPIN team)
KNOWN_CUSTOMERS+="PSA "		# Peugeot-Citroen (SMEG Customer)
KNOWN_CUSTOMERS+="SAIC "	# SAIC (APR-2009 demo)
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
#     + build_{BMW,GENIVI,Intel,MMSE,PSA,SAIC}
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
	echo "ERROR: Should configure CUSTOMER - Read script"
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

if [ "$OPT_REMOVE" = "true" ]; then
	echo "INFO: Censoring VM for CUSTOMER=$CUSTOMER"
	RMTREE=rm -rf
else
	echo "WARNING: Dry run for CUSTOMER=$CUSTOMER - Set OPT_REMOVE=true to actually remove directories"
	RMTREE="echo TODO: rm -rf"
fi

# -----------------------------------------------------------------------------
# Handle $HOME/...
#
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE $HOME/.mozilla || exit 1
	$RMTREE $HOME/.ssh || exit 1
	$RMTREE $HOME/.subversion || exit 1
fi

# -----------------------------------------------------------------------------
# Handle /opt/LUPIN/...
LUPIN_TOPDIR=/opt/LUPIN/code/trunk
#
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/apps || exit 1
fi
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/area_51 || exit 1
fi
if [ $CUSTOMER != LUPIN ]; then
	# TODO: How to deal with admin_scripts ???
	$RMTREE $LUPIN_TOPDIR/misc || exit 1
fi
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/mm_sw || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_BMW* || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != GENIVI -a $CUSTOMER != LUPIN -a $CUSTOMER != PSA ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_GENIVI* || exit 1
fi
if [ $CUSTOMER != GENIVI -a $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_Intel* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != MMSE ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_MMSE* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != PSA ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_PSA* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != SAIC ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/build_SAIC* || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/cust_BMW* || exit 1
fi
if [ $CUSTOMER != BMW -a $CUSTOMER != GENIVI -a $CUSTOMER != LUPIN -a $CUSTOMER != PSA ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/cust_GENIVI* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != PSA ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/cust_PSA* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != SAIC ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/cust_SAIC* || exit 1
fi
if [ $CUSTOMER != LUPIN ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/mmse_experimental* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != MMSE ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/mmse_proprietary* || exit 1
fi
if [ $CUSTOMER != LUPIN -a $CUSTOMER != MMSE ]; then
	$RMTREE $LUPIN_TOPDIR/wrlinux/layers/zzz_empty* || exit 1
fi

# -----------------------------------------------------------------------------
# Handle /opt/WindRiver/...
#
if [ $CUSTOMER != LUPIN -a $CUSTOMER != MMSE ]; then
	$RMTREE /opt/WindRiver/license/* || exit 1
fi

echo "INFO: Virtual Machine censored for CUSTOMER=$CUSTOMER"
exit 0

# === EOF ===
