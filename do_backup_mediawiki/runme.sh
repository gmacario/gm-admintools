#!/bin/sh

set -x

mkdir -p /backup/Backup_MySQL/inno10 || exit 1
ssh macario@inno10.venaria.marelli.it "(cd /home/macario/do_backup_mysql; ./automysqlbackup.sh)"
scp -r macario@inno10.venaria.marelli.it:/home/macario/do_backup_mysql/backups /backup/Backup_MySQL/inno10

# === EOF ===
