#!/bin/bash

# =============================================================================
# Project:	LUPIN
#
# Purpose:	Remove cached Subversion auth files
#
# Language:	GNU bash script
#
# Note:		Should configure username,etc.
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

#set -x

AUTHFILES=${HOME}/.subversion/auth/svn.simple/*

if [ $(ls ${AUTHFILES} 2>/dev/null | wc -l) = 0 ]; then
	echo "You do not have cached SVN auth files"
	exit 0
fi

echo "The following SVN credentials are currently saved:"

for entry in ${AUTHFILES} ; do
	awk '
BEGIN	{state = 0}
/^K/	{state = 1; next}
/^V/	{state = 2; next}
state == 1	{
	key=$0
	#print "DBG: state=" state ": got key=" key
	}
state == 2	{
	value=$0;
	#print "DBG: state=" state ": got value=" value
	#print "DBG:key=" key ", value=" value
	if (key == "username") {
		username=value;
	}
	if (key == "svn:realmstring") {
		realm=value;
	}
	state = 0;
	}
END	{
	#print "DBG:END"
	print username "\t" realm
	}
	' ${entry}
done

echo -n "Do you want to remove them (YES/no)? "
read ok

if [ ${ok} == "YES" ]; then
	rm ${AUTHFILES}
	echo "Removed SVN auth files"
else
	echo "Did not removed auth files"
fi


# === EOF ===
