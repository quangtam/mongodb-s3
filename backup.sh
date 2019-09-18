#!/bin/sh

# Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region, remember add permission for IAM can read/ write to S3)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# DB host (secondary preferred as to avoid impacting primary performance)
DB_HOST=127.0.0.1
DB_PORT=27017
DB_NAME=example
BACKUP_FULL_DB=0 #0: Backup single database; 1: Backup all databases

# S3 bucket name
BUCKET=s3-bucket-name

# Linux user account
USER=ubuntu

# Current time
TIME=$(date +"%Y-%m-%d")

# Backup directory
DEST=/home/$USER/tmp

# Tar file of backup directory
BACKUP_DB_FILE="mongodb-s3-backup-$DB_NAME-$TIME.gz"
BACKUP_FULL_FILE="mongodb-s3-backup-FULL-$TIME.gz"

# Create backup dir (-p to avoid warning if already exists)
mkdir -p $DEST

# Log
echo "Backing up $DB_HOST/$DB_NAME to s3://$BUCKET/ on $TIME";

# Dump from mongodb host into backup archive file
if $BACKUP_FULL_DB; then
   BACKUP_FILE=$BACKUP_DB_FILE
   mongodump --host $DB_HOST --port $DB_PORT --archive=$DEST/$BACKUP_FILE --gzip -d $DB_NAME
else
   #TODO: Backup all DB
   BACKUP_FILE=BACKUP_FULL_FILE
   mongodump --host $DB_HOST --port $DB_PORT --archive=$DEST/$BACKUP_FILE --gzip
fi

# Upload tar to s3
aws s3 cp $DEST/$BACKUP_FILE s3://$BUCKET/$BACKUP_FILE

# Remove tmp file locally
rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$BACKUP_FILE"