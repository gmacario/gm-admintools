#!/bin/sh

set -x -e

#[ `whoami` != root ] && exit 1

sudo ./runme2.sh 2>&1 | tee partdump.log

# === EOF ===
