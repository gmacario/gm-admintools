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
	transtable["mstocchino"] = "stocchino";
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
