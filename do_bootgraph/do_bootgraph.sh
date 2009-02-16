#!/bin/sh

# Required:	perl
#
# Optional:	patch wget

#set -x

#upstream=http://lxr.linux.no/linux+v2.6.28.5
upstream=http://ftp.gnu.org/tmp/linux-libre-fsf2_2.6.28/linux-2.6.28

# Work directory
workdir=targets/`hostname`
#workdir=targets/micino
#
# Uncomment if working across target (data should exist in workdir)
#OPT_CROSS_TARGET=true
#
# Output file
outfile=$workdir/output.svg

echo "INFO: do_bootgraph v0.1"

if [ ! -e bootgraph.pl ]; then
	wget $upstream/scripts/bootgraph.pl
	cat patches/*.diff | patch -p0
fi

if [ "$OPT_CROSS_TARGET" = "true" ]; then
	echo INFO: Taking boot time information from directory $workdir
else
	echo INFO: Saving boot time information to directory $workdir
	mkdir -p $workdir || exit 1
	if [ -e /proc/config.gz ]; then
		zcat /proc/config.gz >$workdir/config.txt
	else
		echo WARNING: Make sure that kernel is built with CONFIG_PRINTK_TIME=y
	fi
	cat /proc/cmdline >$workdir/cmdline.txt
	dmesg >$workdir/dmesg.txt
fi

if [ ! -e $workdir ]; then
	echo ERROR: work directory $workdir does not exist
	exit 1
fi

if [ -e $workdir/config.txt ]; then
	grep -e CONFIG_PRINTK_TIME $workdir/config.txt >/dev/null
	retval=$?
	#echo DBG: retval=$retval
	if [ $retval -ne 0 ]; then
		echo ERROR: Please configure kernel with CONFIG_PRINTK_TIME=y
		exit 1
	fi
fi

grep "printk.time=1" $workdir/cmdline.txt >/dev/null
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo "ERROR: Please append 'printk.time=1' to kernel bootcmd"
	exit 1
fi

grep "initcall_debug" $workdir/cmdline.txt >/dev/null
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	echo "ERROR: Please append 'initcall_debug' to kernel bootcmd"
	exit 1
fi

cat $workdir/dmesg.txt | perl bootgraph.pl >$outfile
retval=$?
#echo DBG: retval=$retval
if [ $retval -ne 0 ]; then
	cat $outfile
	rm -f $outfile
	echo "ERROR: bootgraph.pl returned error $retval"
	exit 1
fi
echo "INFO: Boot graph saved as $outfile"

exit 0

# === EOF ===
