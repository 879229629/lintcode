#!/bin/sh
#
# MySQL backup script
# GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost' IDENTIFIED BY 'password';
# find "$backupfolder" -name db_backup_* -mtime +365 -exec rm {} \;

set -e

usage ()
{
  echo 'Usage : Script --db_name <db_name>'
  exit 1
}

while [ "$1" != "" ]; do
case $1 in
        --db_name )  shift
                     DB_NAME=$1
                     ;;
        * )          break ;; 
    esac
    shift
done

if [ "$DB_NAME" = "" ]
then
    usage
fi

NOW="$(date +'%Y%m%d%H%M%S')"
YMD="$(date +'%Y%m%d')"

mysql_user="backup"
mysql_password="123456"
mysql_host="localhost"
mysql_port=3306
mysql_db_name=$DB_NAME

backupdir="/Users/steven/tmp/backup/data/"
backupfolder="${backupdir}/${YMD}"
fullpathbackupfile_schema="$backupfolder/back_${mysql_db_name}_${NOW}.schema.sql"
fullpathbackupfile="$backupfolder/back_${mysql_db_name}_${NOW}.sql"


echo "*** backup mysql db <${mysql_db_name}> at ${backupfolder}"

if [ ! -d "$backupdir" ]; then
	echo "no existed dir: $backupdir"
	exit 1
fi

mkdir -p $backupfolder

echo "mysqldump started at $(date +'%d-%m-%Y %H:%M:%S')"
mysqldump -d --single-transaction --host=${mysql_host} \
	--port=${mysql_port} --user=${mysql_user} --password=${mysql_password} ${mysql_db_name} > "$fullpathbackupfile_schema"

if [ $? != 0 ] ; then echo "mysqldump failed!"  ; exit 1 ; fi

mysqldump --single-transaction --host=${mysql_host} \
	--port=${mysql_port} --user=${mysql_user} --password=${mysql_password} ${mysql_db_name} > "$fullpathbackupfile"

if [ $? != 0 ] ; then echo "mysqldump failed!"  ; exit 1 ; fi

echo "gzip start at $(date +'%d-%m-%Y %H:%M:%S')"
gzip ${fullpathbackupfile}

echo "mysqldump finished at $(date +'%d-%m-%Y %H:%M:%S')"
echo "operation finished at $(date +'%d-%m-%Y %H:%M:%S')"
echo "******* success **********"

