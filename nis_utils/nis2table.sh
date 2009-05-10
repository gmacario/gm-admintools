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

set -e

OUTFILE=tables/`ypdomainname`_users.csv

mkdir -p `dirname ${OUTFILE}`

(ypcat passwd  || exit 1 ) | awk '
BEGIN	{
	printf("%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n", \
		"! LASTNAME", "firstname", "company", "username", \
		"uid", "gid", \
		"pass_enc", "homedir", "shell", \
		"in_MotoGP", "in_MotoGB");
	FS=":"
	#
	FLAG_MOTOGP = 1;
	FLAG_MOTOGB = 2;
	#
	lupin_users["faghemo"]   = "MOTOGP|MOTOGB";
	lupin_users["alloua"]    = "MOTOGP";
	lupin_users["billiet"]   = "MOTOGP|MOTOGB";
	lupin_users["sbosco"]    = "MOTOGP|MOTOGB";
	lupin_users["cavallot"]  = "MOTOGP|MOTOGB";
	lupin_users["cerato"]    = "MOTOGP|MOTOGB";
	lupin_users["damiano"]   = "MOTOGB";
	lupin_users["desana"]    = "MOTOGP|MOTOGB";
	lupin_users["paolodoz"]  = "MOTOGP|MOTOGB";
	lupin_users["ferrara"]   = "MOTOGP|MOTOGB";
	lupin_users["garcea"]    = "MOTOGP|MOTOGB";
	lupin_users["ghiazza"]   = "MOTOGP|MOTOGB";
	lupin_users["gilforte"]  = "MOTOGP|MOTOGB";
	lupin_users["giraudo"]   = "MOTOGP";
	lupin_users["macario"]   = "MOTOGP|MOTOGB";
	lupin_users["rmarino"]   = "MOTOGP";
	lupin_users["martorel"]  = "MOTOGP";
	lupin_users["mocci"]     = "MOTOGP|MOTOGB";
	lupin_users["ginnuzzi"]  = "MOTOGP|MOTOGB";
	lupin_users["copalma"]   = "MOTOGP|MOTOGB";
	lupin_users["parenti"]   = "MOTOGP|MOTOGB";
	lupin_users["pierri"]    = "MOTOGP|MOTOGB";
	lupin_users["pirra"]     = "MOTOGP|MOTOGB";
	lupin_users["ponchion"]  = "MOTOGP|MOTOGB";
	lupin_users["angrusso"]  = "MOTOGP|MOTOGB";
	lupin_users["asanna"]    = "MOTOGP|MOTOGB";
	lupin_users["sartoric"]  = "MOTOGP|MOTOGB";
	lupin_users["serrett"]   = "MOTOGP|MOTOGB";
	lupin_users["asimmini"]  = "MOTOGP|MOTOGB";
	lupin_users["sponza"]    = "MOTOGP|MOTOGB";
	lupin_users["stocchino"] = "MOTOGP|MOTOGB";
	lupin_users["violino"]   = "MOTOGP|MOTOGB";
	#
	# New users to be added
	#lupin_users["fmocci"]    = "MOTOGP|MOTOGB";
	#lupin_users["nparolini"] = "MOTOGP|MOTOGB";
	#lupin_users["ppantaleo"] = "MOTOGP|MOTOGB";
	#lupin_users["agarcea"]   = "MOTOGP|MOTOGB";
	#lupin_users["msanapo"]   = "MOTOGP|MOTOGB";
	}
//	{
	#print "DBG: $0=" $0
	username=$1
	pass_enc=$2
	uid=$3
	gid=$4
	displayname=$5
	homedir=$6
	shell=$7
	#
	flastname=gensub(/[\ ]*\([a-zA-Z\ \-]*\).*$/, "", "g", displayname);
	firstname=gensub(/\ [a-zA-Z]*$/, "", "g", flastname);
	lastname=toupper(gensub(/.*\ /, "", "g", flastname));
	#
	n_sub = 0;
	company = displayname;
	n_sub += gsub(/^(.*\()/, "", company);
	n_sub += gsub(/(\).*)$/, "", company);
	company = (n_sub == 2) ? company : "Marelli";
	#
	in_MotoGP = ((username in lupin_users) && \
		index("MOTOGP", lupin_users[username]) >= 0) ? 1 : 0;
	in_MotoGB = ((username in lupin_users) && \
		index("MOTOGB", lupin_users[username]) >= 0) ? 1 : 0;
	#
	#print "DBG: displayname=" displayname
	#print "DBG: lastname=" lastname
	#print "DBG: firstname=" firstname
	#print "DBG: company=" company
	#print "DBG: in_MotoGP=" in_MotoGP
	#print "DBG:"
	#
	printf("%s;%s;%s;%s;%d;%d;%s;%s;%s;%d;%d\n", \
		lastname, firstname, company, username, \
		uid, gid, \
		pass_enc,homedir,shell, \
		in_MotoGP, in_MotoGB);
	}
END	{
	}
' | tee nis2table.log | sort >${OUTFILE}

echo "INFO: Results saved under ${OUTFILE}"

# === EOF ==
