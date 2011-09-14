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
#	./ssh-tunnel.sh macario@lupin10.venaria.marelli.it 5000
#
# TODO: STILL DEBUGGING...
# ============================================================================

# ---------------------------------------------------------------------------
# Configurable parameters
# ---------------------------------------------------------------------------

#if [ "${TUNNEL}" = "" ]; then
#	TUNNEL=macario@lupin01.venaria.marelli.it
#fi

#if [ "${REMOTE_USER}" = "" ]; then
#	# $REMOTE_USER is the name of the remote user
#	REMOTE_USER=`whoami`
#fi

#if [ "${REMOTE_HOST}" = "" ]; then
#	# $REMOTE_HOST is the name of the remote system
#	REMOTE_HOST=my.home.system
#fi

#if [ "${REMOTE_PORT}" = "" ]; then
#	# $REMOTE_PORT is the remote port number that will be used
#	# to tunnel back to this system
#	REMOTE_PORT=5000
#fi

# ---------------------------------------------------------------------------
# Main Program
# ---------------------------------------------------------------------------

set -x
#set -e		 # DO NOT set -e since some commands are expected to fail...

PROGNAME=`basename $0`
echo "INFO: ${PROGNAME} - v0.2"

echo "DEBUG: Starting on `date`"

if [ $# -lt 2 ]; then
    echo "Usage: ${PROGNAME} remote_user@remote_host remote_port"
    exit 1
fi

REMOTE_USER=`echo $1 | sed -e 's/\@.*$//'`
REMOTE_HOST=`echo $1 | sed -e 's/^.*@//'`
shift

REMOTE_PORT=$1
shift

#echo "DEBUG: REMOTE_USER=${REMOTE_USER}"
#echo "DEBUG: REMOTE_HOST=${REMOTE_HOST}"
#echo "DEBUG: REMOTE_PORT=${REMOTE_PORT}"

# $COMMAND is the command used to create the reverse ssh tunnel
COMMAND="ssh -q -N -R ${REMOTE_PORT}:localhost:22 ${REMOTE_USER}@${REMOTE_HOST}"

# Is the tunnel up? Perform two tests:

echo "INFO: Establishing reverse ssh to ${REMOTE_USER}@${REMOTE_HOST} on port ${REMOTE_PORT}"

# 1. Check for relevant process ($COMMAND)
pgrep -f -x "$COMMAND"
# >/dev/null 2>&1
retval=$?
echo "DEBUG: retval=$retval"
[ $retval ] || $COMMAND

#$COMMAND

# 2. Test tunnel by looking at "netstat" output on $REMOTE_HOST
ssh "${REMOTE_USER}@${REMOTE_HOST}" \
	netstat -an | \
	egrep "tcp.*:${REMOTE_PORT}.*LISTEN" # > /dev/null 2>&1
if [ $? -ne 0 ] ; then
   pkill -f -x "$COMMAND"
   $COMMAND
fi

#ssh "${TUNNEL_USER}@${TUNNEL_HOST}" "ssh ${REMOTE_USER}@${REMOTE_HOST} $*"

echo "DEBUG: Ending on `date`"

# === EOF ===
