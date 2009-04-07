#!/bin/sh

#set -x

BACKUPDIR=/backup/Backup_webapps/lupin08
REMOTEUSER=user01
REMOTEHOST=lupin08.venaria.marelli.it
REMOTEDIR=/home/user01/do_backup_webapps

DBS=""
DBS+="mediawiki-1.14.0 "
DBS+="lupinwiki "
DBS+="bugzilla "
#DBS+="osstbox "

WEBAPPS_ARCHIVE=`date '+%Y%m%d'`-webapps_install.tgz

echo "INFO: $0 v0.1"

# Backup MySQL
echo "INFO: Creating backup of MySQL DB from $REMOTEHOST"
mkdir -p $BACKUPDIR || exit 1
ssh $REMOTEUSER@$REMOTEHOST "(cd $REMOTEDIR && ./automysqlbackup_lupin08.sh)" || exit 1

echo "INFO: Copying backup of MySQL DB from $REMOTEHOST"
scp -r $REMOTEUSER@$REMOTEHOST:$REMOTEDIR/mysql_backups $BACKUPDIR || exit 1

# Backup MediaWiki engine
echo "INFO: Backing up webapps files at $REMOTEHOST"
ssh $REMOTEUSER@$REMOTEHOST \
	"(cd /var/www && tar cvz $DBS)" \
	> $BACKUPDIR/$WEBAPPS_ARCHIVE || exit 1

## Backup Images
#for wiki in $WIKIS; do
#	echo "INFO: Backing up images from $wiki at $REMOTEHOST"
#	mkdir -p $BACKUPDIR/$wiki || exit 1
#	scp -r $REMOTEUSER@$REMOTEHOST:/var/www/$wiki/images \
#		$BACKUPDIR/$wiki || exit 1
#done

# Backup MediaWiki engine

# === EOF ===
