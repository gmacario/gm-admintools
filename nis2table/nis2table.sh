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

(ypcat passwd  || exit 1 ) | awk '
BEGIN	{
	printf("%s;%s;%s;%s;%s\n", "* LASTNAME", "firstname", "username", "in_MotoGP", "in_MotoGB");
	FS=":"
	#
	FLAG_MOTOGP = 1;
	FLAG_MOTOGB = 2;
	#
	lupin_users["angrusso"]  = "MOTOGP MOTOGB";
	lupin_users["asanna"]    = "MOTOGP MOTOGB";
	lupin_users["asimmini"]  = "MOTOGP MOTOGB";
	lupin_users["cavallot"]  = "MOTOGP MOTOGB";
	lupin_users["cerato"]    = "MOTOGP MOTOGB";
	lupin_users["desana"]    = "MOTOGP MOTOGB";
	lupin_users["faghemo"]   = "MOTOGP MOTOGB";
	lupin_users["ferrara"]   = "MOTOGP MOTOGB";
	lupin_users["ghiazza"]   = "MOTOGP MOTOGB";
	lupin_users["ginnuzzi"]  = "MOTOGP MOTOGB";
	lupin_users["macario"]   = "MOTOGP MOTOGB";
	lupin_users["paolodoz"]  = "MOTOGP MOTOGB";
	lupin_users["pierri"]    = "MOTOGP MOTOGB";
	lupin_users["pirra"]     = "MOTOGP MOTOGB";
	lupin_users["ponchion"]  = "MOTOGP MOTOGB";
	lupin_users["sartoric"]  = "MOTOGP MOTOGB";
	lupin_users["serrett"]   = "MOTOGP MOTOGB";
	lupin_users["sponza"]    = "MOTOGP MOTOGB";
	lupin_users["stocchino"] = "MOTOGP MOTOGB";
	lupin_users["violino"]   = "MOTOGP MOTOGB";
	#
	# New users to be added
	#lupin_users["fmocci"]    = "MOTOGP MOTOGB";
	#lupin_users["nparolini"] = "MOTOGP MOTOGB";
	#lupin_users["ppantaleo"] = "MOTOGP MOTOGB";
	#lupin_users["agarcea"]   = "MOTOGP MOTOGB";
	#lupin_users["msanapo"]   = "MOTOGP MOTOGB";
	}
//	{
	#print "DBG: $0=" $0
	username=$1
	#print "DBG: username=" username
	#if (! (username in lupin_users) ) next;
	#
	firstname=gensub(/\ [a-zA-Z]*$/, "", "g", $5);
	lastname=toupper(gensub(/.*\ /, "", "g", $5));
	in_MotoGP = ((username in lupin_users) && index("MOTOGP", lupin_users[username]) >= 0) ? "Yes" : "No";
	in_MotoGB = ((username in lupin_users) && index("MOTOGB", lupin_users[username]) >= 0) ? "Yes" : "No";
	#
	# Fixup macario firstname
	if (firstname == "Giampaolo") firstname="Gianpaolo";
	#print "DBG: firstname=" firstname
	#print "DBG: lastname=" lastname
	#print "DBG: in_MotoGP=" in_MotoGP
	#print "DBG:"
	#
	printf("%s;%s;%s;%s;%s\n", lastname, firstname, username, in_MotoGP, in_MotoGB);
	}
END	{
	}
' | sort >lupin_users.csv

# === EOF ==
