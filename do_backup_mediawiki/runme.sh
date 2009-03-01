#!/bin/sh

#set -x

BACKUPDIR=/backup/Backup_MediaWiki/inno10
REMOTEUSER=macario
REMOTEHOST=inno10.venaria.marelli.it
REMOTEDIR=/home/macario/do_backup_mediawiki

mkdir -p $BACKUPDIR || exit 1
ssh $REMOTEUSER@$REMOTEHOST "(cd $REMOTEDIR && ./automysqlbackup_inno10.sh)"
scp -r $REMOTEUSER@$REMOTEHOST:$REMOTEDIR/mysql_backups $BACKUPDIR

# === EOF ===
