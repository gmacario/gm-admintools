#!/bin/sh

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
#	http://www.brandonhutchinson.com/ssh_tunnelling.html
#
# Usage examples:
#	TUNNEL=macario@lupin01.venaria.marelli.it \
#		ssh-tunnel.sh root@gianpinas.homelinux.net
# ============================================================================

# ---------------------------------------------------------------------------
# Configurable parameters
# ---------------------------------------------------------------------------

#if [ "${TUNNEL}" = "" ]; then
#	TUNNEL=macario@lupin01.venaria.marelli.it
#fi

if [ "${REMOTE_USER}" = "" ]; then
	# $REMOTE_USER is the name of the remote user
	REMOTE_USER=`whoami`
fi

if [ "${REMOTE_HOST}" = "" ]; then
	# $REMOTE_HOST is the name of the remote system
	REMOTE_HOST=my.home.system
fi

if [ "${REMOTE_PORT}" = "" ]; then
	# $REMOTE_PORT is the remote port number that will be used
	# to tunnel back to this system
	REMOTE_PORT=5000
fi

# $COMMAND is the command used to create the reverse ssh tunnel
COMMAND="ssh -q -N -R $REMOTE_PORT:localhost:22 $REMOTE_USER@$REMOTE_HOST"

# ---------------------------------------------------------------------------
# Main Program
# ---------------------------------------------------------------------------

set -x
set -e

PROGNAME=`basename $0`
#echo "INFO: ${PROGNAME} - v0.1"

#if [ $# -lt 1 ]; then
#    echo "Usage: ${PROGNAME} remoteuser@remotehost [commands]"
#    exit 1
#fi

#REMOTE_USER=`echo $1 | sed -e 's/\@.*$//'`
#REMOTE_HOST=`echo $1 | sed -e 's/^.*@//'`
#shift

#echo "DEBUG: REMOTE_USER=$REMOTE_USER"
#echo "DEBUG: REMOTE_HOST=$REMOTE_HOST"

#TUNNEL_USER=`echo "${TUNNEL}" | sed -e 's/\@.*$//'`
#TUNNEL_HOST=`echo "${TUNNEL}" | sed -e 's/^.*@//'`

#echo "INFO: Executing commands to ${REMOTE_USER}@${REMOTE_HOST} through ${TUNNEL_USER}@${TUNNEL_HOST}"
#ssh "${TUNNEL_USER}@${TUNNEL_HOST}" "ssh ${REMOTE_USER}@${REMOTE_HOST} $*"

# Is the tunnel up? Perform two tests:

# 1. Check for relevant process ($COMMAND)
pgrep -f -x "$COMMAND" > /dev/null 2>&1 || $COMMAND

# 2. Test tunnel by looking at "netstat" output on $REMOTE_HOST
ssh $REMOTE_HOST netstat -an | egrep "tcp.*:$REMOTE_PORT.*LISTEN" \
   > /dev/null 2>&1
if [ $? -ne 0 ] ; then
   pkill -f -x "$COMMAND"
   $COMMAND
fi

# === EOF ===