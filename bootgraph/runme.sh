#!/bin/sh

#upstream=http://lxr.linux.no/linux+v2.6.28.5
upstream=http://ftp.gnu.org/tmp/linux-libre-fsf2_2.6.28/linux-2.6.28

if [ ! -e bootgraph.pl ]; then
	wget $upstream/scripts/bootgraph.pl
fi

dmesg | perl bootgraph.pl >output.svg

# === EOF ===
