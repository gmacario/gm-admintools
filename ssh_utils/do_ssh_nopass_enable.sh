#!/bin/sh
# ============================================================================
# Project:	LUPIN
#
# Description:	Enable SSH authentication without password request
#
# Language:	Unix Shell Script
#
# Required packages:
#	openssh-client
#
# See also:
#	LupinWiki:[[Secure_authentication_with_SSH_without_password_request]]
#
# Usage examples:
#	do_ssh_nopass_enable.sh root@gianpinas.homelinux.net
# ============================================================================

# ---------------------------------------------------------------------------
# Configurable parameters
# ---------------------------------------------------------------------------

# NONE

# ---------------------------------------------------------------------------
# Main Program
# ---------------------------------------------------------------------------

#set -x
set -e

PROGNAME=`basename $0`
echo "INFO: ${PROGNAME} - v0.2"

if [ $# -lt 1 ]; then
    echo "Usage: ${PROGNAME} remoteuser@remotehost"
    exit 1
fi

REMOTEUSER=`echo $1 | sed -e 's/\@.*$//'`
REMOTEHOST=`echo $1 | sed -e 's/^.*@//'`

#echo "DEBUG: REMOTEUSER=$REMOTEUSER"
#echo "DEBUG: REMOTEHOST=$REMOTEHOST"

echo "INFO: Enabling automatic login to ${REMOTEUSER}@${REMOTEHOST}"
if [ ! -e ${HOME}/.ssh/id_rsa.pub ]; then
    echo "WARNING: Missing SSH public/private keypair"
    ssh-keygen
fi
cat ${HOME}/.ssh/id_rsa.pub | ssh ${REMOTEUSER}@${REMOTEHOST} \
"cd .ssh && cat >>authorized_keys && chmod 640 authorized_keys"

# === EOF ===
