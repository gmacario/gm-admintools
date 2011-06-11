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
	#transtable[""] = "";

	# Translate MMSE (employees and contractors) users
	#           old_user              new_user
	# -------------------------------------------------
	#transtable["faghemo"] = "faghemo";
	transtable["tallaoua"]         = "allaoua";
	#transtable["?"] = "santonel";
	#transtable["fbasso"] = "fbasso";
	transtable["cbesozzi"]         = "besozzi";
	transtable["ebilliet"]         = "billiet";
	#transtable["sbosco"] = "sbosco";
	#transtable["ebruci"] = "ebruci";
	#transtable["lbuso"] = "lbuso";
	#transtable["?"] = "calabro";
	transtable["ccambursano"]      = "cambursa";
	transtable["gcasanova"]        = "casanova";
	transtable["pcavallotti"]      = "cavallot";
	transtable["acerato"]          = "cerato";
	#transtable["?"] = "cingolan";
	transtable["yclemenceau"]      = "clemence";
	#transtable["?"] = "copetti";
	transtable["mcurti"] = "curti";
	transtable["adamiano"]         = "damiano";
	transtable["ddesana"]          = "desana";
	transtable["pdoz"]             = "paolodoz";
	#transtable["?"] = "faggiani";
	transtable["sfarina"]          = "farina";
	transtable["rferrara"]         = "ferrara";
	transtable["lfresi"]           = "fresi";
	#transtable["?"] = "garberog";
	transtable["agarcea"]          = "garcea";
	#transtable["?"] = "gennarin";
	transtable["mghiazza"]         = "ghiazza";
	transtable["ggiacoia"]         = "giacoia";
	#transtable["?"] = "gilforte";
	transtable["ggiraudo"]         = "giraudo";
	transtable["egraglia"] = "graglia";
	#transtable["?"] = "grellier";
	transtable["rherard"]          = "herard";
	#transtable["pleone"] = "pleone";
	#transtable["?"] = "lococo";
	transtable["elosego"]          = "losego";
	transtable["gmacario"]         = "macario";
	transtable["amaddau"]          = "maddau";
	transtable["mmarcia"]          = "marcia";
	#transtable["rmarino"] = "rmarino";
	#transtable["martorel"] = "martorel";
	transtable["fmocci"]           = "mocci";
	transtable["amurru"]           = "murru";
	transtable["mnassi"]           = "nassi";
	transtable["mnoberasco"]       = "noberasco";
	transtable["gnuzzi"]           = "ginnuzzi";
	#transtable["sorlandi"] = "sorlandi";
	transtable["cpalma"]           = "copalma";
	transtable["dpanero"]          = "panero";
	transtable["ppantaleo"]        = "ppantale";
	transtable["lparenti"]         = "parenti";
	transtable["nparolini"]        = "parolini";
	transtable["lpicerno"]         = "picerno";
	transtable["mpierri"]          = "pierri";
	#transtable["epinna"] = "epinna";
	transtable["ppinna"]           = "pinna";
	transtable["gpirra"]           = "pirra";
	transtable["gponchione"]       = "ponchion";
	transtable["pporcu"]           = "porcu";
	#transtable["?"] = "re";
	#transtable["mrocca"] = "mrocca";
	#transtable["?"] = "rodino";
	transtable["arusso"]           = "angrusso";
	#transtable["fsalerno"] = "fsalerno";
	transtable["msanapo"]          = "sanapo";
	#transtable["asanna"] = "asanna";
	transtable["asannio"]          = "sannio";
	#transtable["?"] = "sartoric";
	#transtable["?"] = "serre";
	transtable["eserretti"]        = "serrett";
	#transtable["asimmini"] = "asimmini";
	transtable["msoddu"]           = "soddu";
	transtable["csponza"]          = "sponza";
	transtable["mstocchino"]       = "stocchino";
	#transtable["?"] = "strazzullo";
	#transtable["?"] = "terree";
	#transtable["ftosetto"] = "?";
	transtable["mturinetto"]       = "turinett";
	transtable["eturpault"]        = "turpault";
	#transtable["?"] = "tuttobene";
	transtable["wviolino"] = "violino";
	transtable["rzompi"]           = "zompi";

	# TODO: Translate non-MMSE users
	#           old_user              new_user
	# -------------------------------------------------
	#transtable["lbelluccini"] = "?";
	#transtable["rlupin"] = "?";
	#transtable["fpagin"] = "?";
	#transtable["mtorchiano"] = "?";
	#transtable["mviolante"] = "?";
	
	# Translate repository names
	#           old_repos             new_repos
	# -------------------------------------------------
	transtable["inno:"]            = "lupin:";
	transtable["osstbox:"]         = "osstlab:";

	# Translate hostnames
	#           old_hostname          new_hostname
	# -------------------------------------------------
	transtable["inno05"]           = "lupin05";

	}
//	{
	for (word in transtable) {
	    gsub(word, transtable[word], $0);
	}
	print $0
	}
' ${oldauth_file} >dav_svn.authz

set -x

#diff -u $oldauth_file dav_svn.authz
diff -y -W 165 $oldauth_file dav_svn.authz |less

# === EOF ===
