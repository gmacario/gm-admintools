#!/bin/sh
# =============================================================================
# Project:	LUPIN
#
# Description:	Script to publish a VMware VM to NAS
#
# Revision History:
#	19-JAN-2009	macario		Initial version
# =============================================================================

NAS_SHARE=//itven1nnas1.venaria.marelli.it/lupin
NAS_USER=macario
NAS_DOMAIN=mmemea
NAS_PASSWORD=
#NAS_MOUNTPOINT=/mnt/lupin
#NAS_CHECKFILE=${NAS_MOUNTPOINT}/this_is_itven1nnas1_lupin.txt

VM_REPOSITORY="/var/lib/vmware/Virtual Machines"
#VM_NAME=lupin10
VM_NAME=Ubuntu804-WR_PFIdec19
VM_BACKUPDIR=/Backup_VM
#VM_RELEASEDIR=/Master_Disks/Build_VM

# -----------------------------------------------------------------------------
#set -x

## Make sure NAS_SHARE is mounted
#if [ ! -f ${NAS_CHECKFILE} ]; then
#    sudo mkdir -p ${NAS_MOUNTPOINT}
#    if [ "${NAS_PASSWORD}" = "" ]; then
#        read -p "Enter NAS_PASSWORD: " NAS_PASSWORD
#    fi
#    sudo smbmount ${NAS_SHARE} ${NAS_MOUNTPOINT} \ 
#        -o username="${NAS_USER}",password="${NAS_PASSWORD}",workgroup=${NAS_DOMAIN}
##    sudo mount -t smbfs ${NAS_SHARE} ${NAS_MOUNTPOINT} \ 
##        -o username="${NAS_USER}",password="${NAS_PASSWORD}",workgroup=${NAS_DOMAIN}
#
#fi
#if [ ! -f ${NAS_CHECKFILE} ]; then
#    echo Cannot access file ${NAS_CHECKFILE}
#    exit 1
#fi


# Sanity checks
if [ ! -d "${VM_REPOSITORY}/${VM_NAME}" ]; then
    echo Cannot find VM "${VM_NAME}" under "${VM_REPOSITORY}"
    exit 1
fi
# Make sure that VM is stopped
VM_ISLOCKED=`find "${VM_REPOSITORY}/${VM_NAME}" -name "*.lck" | wc -l`
#echo DBG: VM_ISLOCKED=${VM_ISLOCKED}
if [ ${VM_ISLOCKED} -gt 0 ]; then
    echo VM ${VM_NAME} is currently locked
    exit 1
fi

BCK_FILENAME=`date +%Y%m%d`-${VM_NAME}
#CHUNKSIZE=600m 

# TODO: Should find optimal compromise between size and compression speed...
if [ ! -e ${BCK_FILENAME}.tgz ]; then
    echo "*** Please supply password for ${USER} on ${HOSTNAME} if requested"
    (cd "${VM_REPOSITORY}" && \
	sudo tar cvz ${VM_NAME}) >${BCK_FILENAME}.tgz || exit 1
    rm -f md5sum.txt
fi

# Calculate tarball checksum
md5sum ${BCK_FILENAME}.tgz >md5sum.txt || exit 1

# Copy .tar.bz2 to NAS_SHARE
echo "*** Please supply password for ${NAS_USER} on ${NAS_SHARE} if requested"
echo "cd ${VM_BACKUPDIR}/
mkdir ${BCK_FILENAME}
cd ${BCK_FILENAME}
put ${BCK_FILENAME}.tgz
put md5sum.txt
dir
quit" \
| smbclient --user ${NAS_USER} --workgroup ${NAS_DOMAIN} ${NAS_SHARE} || exit 1

# === EOF ===
