#!/bin/sh
#
# TODO TODO TODO: STILL DEBUGGING IT!!!
#
# ============================================================================
# Project:	LUPIN
#
# Description:	Tunnel shell commands through SSH
#
# Language:	Unix Shell Script
#
# Required packages:
#	openssh-client
#
# See also:
#	http://www.revsys.com/writings/quicktips/ssh-tunnel.html
#
# Usage examples:
#	TUNNEL=macario@lupin01.venaria.marelli.it \
#		ssh-tunnel.sh root@gianpinas.homelinux.net
# ============================================================================

# ---------------------------------------------------------------------------
# Configurable parameters
# ---------------------------------------------------------------------------

if [ "${TUNNEL}" = "" ]; then
	TUNNEL=macario@lupin01.venaria.marelli.it
fi

# ---------------------------------------------------------------------------
# Main Program
# ---------------------------------------------------------------------------

#set -x
set -e

PROGNAME=`basename $0`
#echo "INFO: ${PROGNAME} - v0.1"

if [ $# -lt 1 ]; then
    echo "Usage: ${PROGNAME} remoteuser@remotehost [commands]"
    exit 1
fi

REMOTEUSER=`echo $1 | sed -e 's/\@.*$//'`
REMOTEHOST=`echo $1 | sed -e 's/^.*@//'`
shift

#echo "DEBUG: REMOTEUSER=$REMOTEUSER"
#echo "DEBUG: REMOTEHOST=$REMOTEHOST"

TUNNELUSER=`echo "${TUNNEL}" | sed -e 's/\@.*$//'`
TUNNELHOST=`echo "${TUNNEL}" | sed -e 's/^.*@//'`

#echo "INFO: Executing commands to ${TARGETUSER}@${TARGETHOST} through ${TUNNELUSER}@${TUNNELHOST}"

#set -x
ssh "${TUNNELUSER}@${TUNNELHOST}" "ssh ${REMOTEUSER}@${REMOTEHOST} $*"

# === EOF ===
