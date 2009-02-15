#!/bin/sh

#upstream=http://lxr.linux.no/linux+v2.6.28.5
upstream=http://ftp.gnu.org/tmp/linux-libre-fsf2_2.6.28/linux-2.6.28

if [ ! -e bootgraph.pl ]; then
	wget $upstream/scripts/bootgraph.pl
fi

#zcat /proc/config.gz | grep CONFIG_PRINTK_TIME || exit 1

cat /proc/cmdline | grep "printk.time=1"
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo Please append 'printk.time=1' to kernel bootcmd
	exit 1
fi

cat /proc/cmdline | grep "initcall_debug"
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo Please append 'initcall_debug' to kernel bootcmd
	exit 1
fi

set -x

dmesg | perl bootgraph.pl >output.svg

# === EOF ===
