#!/bin/sh
#
# Description:	Helper script to deploy a web application

REMOTEUSER=user01
REMOTESITE=lupin08.venaria.marelli.it
BASEDIR=/var/www/lupin-web
REVISION=HEAD

#ssh user01@lupin08.venaria.marelli.it "cd /var/www/lupin-web && svn update"
ssh ${REMOTEUSER}@${REMOTESITE} "cd ${BASEDIR} && svn update -r${REVISION}"

# === EOF ===
