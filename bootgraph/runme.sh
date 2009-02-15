#!/bin/sh

#upstream=http://lxr.linux.no/linux+v2.6.28.5
upstream=http://ftp.gnu.org/tmp/linux-libre-fsf2_2.6.28/linux-2.6.28
outfile=output.svg

if [ ! -e bootgraph.pl ]; then
	wget $upstream/scripts/bootgraph.pl
fi

if [ -e /proc/config.gz ]; then
	zcat /proc/config.gz | grep CONFIG_PRINTK_TIME >/dev/null
	retval=$?
	#echo DBG: retval=$retval
	if [ $retval -ne 0 ]; then
		echo Please configure kernel with CONFIG_PRINTK_TIME=y
		exit 1
	fi
fi

cat /proc/cmdline | grep "printk.time=1" >/dev/null
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo Please append 'printk.time=1' to kernel bootcmd
	exit 1
fi

cat /proc/cmdline | grep "initcall_debug" >/dev/null
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo Please append 'initcall_debug' to kernel bootcmd
	exit 1
fi

dmesg | perl bootgraph.pl >$outfile || exit 1
echo INFO: Boot graph saved as $outfile

exit 0

# === EOF ===
