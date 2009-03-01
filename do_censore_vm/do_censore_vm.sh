#!/bin/sh

# This script MUST be run before distributing a VM outside the LUPIN core team
#
# The following directories must be handled:
#
# /home/user01/
#   + .mozilla
#   + .subversion
#
# /opt/LUPIN/code/trunk/
#   + apps/
#   + area_51/
#   + misc/
#     + admin_scripts/
#   + wrlinux/
#     + build_{BMW,GENIVI,Intel,PSA,SAIC}
#     + layers/
#       + cust_{BMW,GENIVI,Intel,PSA,SAIC}
#       + mmse_experimental
#       + mmse_proprietary
#
# /opt/WindRiver/
#   + license


# CUSTOMER should be chosen between one of those:
#	BMW		BMW (EntryNav,NBT)
#	GENIVI		GENIVI (members with access to BMWI-POSR)
#	LUPIN		LUPIN team
#	MMSE		Magneti Marelli (outside the LUPIN team)
#	PSA		Peugeot-Citroen (SMEG Customer)
#	TES		TES (Contractor for OpenGL to SMEG/Linux)
CUSTOMER=clueless

echo "INFO: Censoring VM for CUSTOMER=$CUSTOMER"

# TODO TODO TODO

if [ $CUSTOMER != LUPIN ]; then
	rm -rf /opt/LUPIN/code/trunk/area_51
fi
if [ $CUSTOMER != BMW ]; then
	rm -rf /opt/LUPIN/code/trunk/wrlinux/build_BMW*
fi

# === EOF ===
