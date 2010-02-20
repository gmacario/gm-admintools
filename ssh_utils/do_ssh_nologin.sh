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
# ============================================================================

REMOTEUSER=demo
REMOTEHOST=lupin12.venaria.marelli.it

echo "INFO: Enabling automatic login to ${REMOTEUSER}@${REMOTEHOST}"
if [ ! -e ${HOME}/.ssh/id_rsa.pub ]; then
    ssh-keygen
fi
cat ${HOME}/.ssh/id_rsa.pub | ssh ${REMOTEUSER}@${REMOTEHOST} \
"cd .ssh && cat >>authorized_keys && chmod 640 authorized_keys"

# === EOF ===
