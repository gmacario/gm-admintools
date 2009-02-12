#!/bin/sh
# =============================================================================
# Project:      LUPIN
#
# Description:  Create an Excel table from NIS user database
#
# Language:     Linux Shell Script
#
# Usage example:
#       $ ./nis2table.sh
#
# Package Dependencies:
#       Required:       awk yp-tools
#       Optional:       ?
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

ypcat passwd | awk '
BEGIN	{
	printf("%s;%s;%s\n", " LASTNAME", "firstname", "username");
	FS=":"
	#
	lupin_users["aghemo"] = 1;
	lupin_users["angrusso"] = 1;
	lupin_users["asanna"] = 1;
	lupin_users["asimmini"] = 1;
	lupin_users["cavallot"] = 1;
	lupin_users["cerato"] = 1;
	lupin_users["desana"] = 1;
	lupin_users["ferrara"] = 1;
	#lupin_users["fmocci"] = 1;
	lupin_users["ghiazza"] = 1;
	lupin_users["ginnuzzi"] = 1;
	lupin_users["macario"] = 1;
	lupin_users["paolodoz"] = 1;
	lupin_users["pierri"] = 1;
	lupin_users["pirra"] = 1;
	lupin_users["ponchion"] = 1;
	lupin_users["sartoric"] = 1;
	lupin_users["serrett"] = 1;
	lupin_users["sponza"] = 1;
	lupin_users["stocchino"] = 1;
	lupin_users["violino"] = 1;
	}
//	{
	#print "DBG: $0=" $0
	username=$1
	if (! (username in lupin_users) ) next;
	#
	firstname=gensub(/\ [a-zA-Z]*$/, "", "g", $5);
	lastname=toupper(gensub(/.*\ /, "", "g", $5));
	#print "DBG: username=" username
	#print "DBG: firstname=" firstname
	#print "DBG: lastname=" lastname
	#print "DBG:"
	#
	printf("%s;%s;%s\n", lastname, firstname, username);
	}
END	{
	}
' | sort >lupin_users.csv

# === EOF ==
