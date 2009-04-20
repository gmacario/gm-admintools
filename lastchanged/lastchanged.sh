#!/bin/sh

set -x
set -e

REMOTEUSER=ubuntu
REMOTEHOST=192.168.82.130
BASEDIR=/media/win_d
#BASEDIR=/tmp
FIND_PATTERN="-mtime -7"

LIST=lastchanged.txt
TARBALL=lastchanged.tar.gz

if [ ! -e $LIST ]; then
	ssh $REMOTEUSER@$REMOTEHOST "cd $BASEDIR && find . $FIND_PATTERN -ls" >$LIST
	echo "INFO: Saving list from $LIST"
	exit
else
	echo "INFO: Backing up files from $LIST"
fi

scp $LIST $REMOTEUSR@$REMOTEHOST:/tmp
ssh $REMOTEUSER@$REMOTEHOST "cd $BASEDIR && tar cvz $(find . $FIND_PATTERN)" >$TARBALL

# === EOF ===
