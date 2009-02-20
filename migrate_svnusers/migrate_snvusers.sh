#!/bin/sh
#
# Migrate SVN users from inno05 to lupin05 (on NIS lupin.venaria.marelli.it)

nisusers_file=nisusers.txt
oldauth_file=dav_svn-inno05.authz

if [ ! -e $nisusers_file ]; then
	ypcat passwd | cut -d ':' -f 1 | sort >$nisusers_file || exit 1
fi

if [ ! -e $oldauth_file ]; then
	ssh macario@inno05.venaria.marelli.it \
		"cat /etc/apache2/dav_svn.authz" \
		>$oldauth_file || exit 1
fi

awk '
BEGIN	{
	#transtable["olduser"] = "newuser";
	#transtable[""] = "";
	transtable["mstocchino"] = "stocchino";
	transtable["pdoz"] = "paolodoz";
	transtable["gmacario"] = "macario";
	transtable["gpirra"] = "pirra";
	transtable["cbesozzi"] = "besozzi";
	transtable["ebilliet"] = "billiet";
	transtable["gcasanova"] = "casanova";
	transtable["pcavallotti"] = "cavallot";
	transtable["acerato"] = "cerato";
	transtable["adamiano"] = "damiano";
	transtable["ddesana"] = "desana";
	transtable["sfarina"] = "farina";
	transtable["rferrara"] = "ferrara";
	transtable["lfresi"] = "fresi";
	transtable["mghiazza"] = "ghiazza";
	transtable["mmarcia"] = "marcia";
	transtable["mnoberasco"] = "noberasco";
	transtable["gnuzzi"] = "ginnuzzi";
	transtable["nparolini"] = "parolini";
	transtable["mpierri"] = "pierri";
	transtable["gponchione"] = "ponchion";
	transtable["arusso"] = "angrusso";
	transtable["eserretti"] = "serrett";
	transtable["wviolino"] = "violino";
	transtable["csponza"] = "sponza";
	transtable["elosego"] = "losego";
	transtable["eturpault"] = "turpault";
	transtable["mturinetto"] = "turinett";
	transtable["ppinna"] = "pinna";
	transtable["rherard"] = "herard";
	transtable["yclemenceau"] = "clemence";

	# TODO
	
	#transtable["oldrepos"] = "newrepos";
	transtable["osstbox"] = "osstlab";
	# TODO
	}
//	{
	for (word in transtable) {
	    gsub(word, transtable[word], $0);
	}
	print $0
	}
' ${oldauth_file} >dav_svn.authz

diff -u $oldauth_file dav_svn.authz

# === EOF ===
