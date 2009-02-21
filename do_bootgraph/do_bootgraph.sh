#!/bin/sh
# =============================================================================
# Project:      LUPIN
#
# Description:  Generate a graph out of the Linux kernel boot sequence
#
# Language:     Linux Shell Script
#
# Usage example:
#       $ ./do_bootgraph.sh
#
# Package Dependencies:
#	Required:	perl
#	Optional:	patch wget
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
# Uncomment if working across target (data should exist in workdir)
#OPT_CROSS_TARGET=true
#
# Work directory to store logs
workdir=targets/`hostname`
#workdir=targets/micino
#
# Output file
outfile=$workdir/output.svg

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

#upstream=http://lxr.linux.no/linux+v2.6.28.5
upstream=http://ftp.gnu.org/tmp/linux-libre-fsf2_2.6.28/linux-2.6.28

# -----------------------------------------------------------------------------
# Main Program starts here
echo "INFO: do_bootgraph v0.2"

#set -x

# Source the Perl script from Linux sources and apply local patches
if [ ! -e bootgraph.pl ]; then
	wget $upstream/scripts/bootgraph.pl || exit 1
	cat patches/*.diff | patch -p0 || exit 1
fi

if [ "$OPT_CROSS_TARGET" = "true" ]; then
	echo INFO: Taking boot time information from directory $workdir
else
	echo INFO: Saving boot time information to directory $workdir
	mkdir -p $workdir || exit 1
	if [ -e /proc/config.gz ]; then
		zcat /proc/config.gz >$workdir/config.txt
	else
		config_guess=/boot/config-`uname -r`
		if [ -e $config_guess ]; then
			echo "INFO: Taking kernel configuration from $config_guess"
			cp $config_guess $workdir/config.txt
		else
			echo "WARNING: Cannot guess kernel configuration"
		fi
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
else
	echo "WARNING: No kernel configuration found"
	echo "WARNING: Make sure that kernel has been built with CONFIG_PRINTK_TIME=y"
fi

# Check for specific options in the kernel command line
f_ok=0
for opt in "printk.time=1" "initcall_debug"; do
	grep $opt $workdir/cmdline.txt >/dev/null
	retval1=$?
	#echo DBG: retval1=$retval1
	if [ $retval1 -ne 0 ]; then
		echo "ERROR: Please add option to kernel bootcmd: $opt"
		f_ok=1
	fi
done
if [ $f_ok -ne 0 ]; then
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
