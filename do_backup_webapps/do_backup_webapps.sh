#!/bin/sh

#set -x

BACKUPDIR=/backup/Backup_webapps/lupin08
REMOTEUSER=user01
REMOTEHOST=lupin08.venaria.marelli.it
REMOTEDIR=/home/user01/do_backup_webapps

WIKIS=""
WIKIS+="mediawiki-1.14.0 "
WIKIS+="lupinwiki "
WIKIS+="nbtwiki "
WIKIS+="osstbox "

MEDIAWIKI_ARCHIVE=`date '+%Y%m%d'`-mediawiki_install.tgz

echo "INFO: $0 v0.1"

# Backup MySQL
echo "INFO: Creating backup of MySQL DB from $REMOTEHOST"
mkdir -p $BACKUPDIR || exit 1
ssh $REMOTEUSER@$REMOTEHOST "(cd $REMOTEDIR && ./automysqlbackup_lupin08.sh)" || exit 1

echo "INFO: Copying backup of MySQL DB from $REMOTEHOST"
scp -r $REMOTEUSER@$REMOTEHOST:$REMOTEDIR/mysql_backups $BACKUPDIR || exit 1

# Backup MediaWiki engine
echo "INFO: Backing up MediaWiki engine at $REMOTEHOST"
ssh $REMOTEUSER@$REMOTEHOST \
	"(cd /var/www && tar cvz $WIKIS)" \
	> $BACKUPDIR/$MEDIAWIKI_ARCHIVE || exit 1

## Backup Images
#for wiki in $WIKIS; do
#	echo "INFO: Backing up images from $wiki at $REMOTEHOST"
#	mkdir -p $BACKUPDIR/$wiki || exit 1
#	scp -r $REMOTEUSER@$REMOTEHOST:/var/www/$wiki/images \
#		$BACKUPDIR/$wiki || exit 1
#done

# Backup MediaWiki engine

# === EOF ===
