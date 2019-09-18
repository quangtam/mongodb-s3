# MONGODB S3: Backup & Restore
 1) Name this file `backup.sh` and place it in /home/ubuntu
 2) Run sudo apt-get install awscli to install the AWSCLI
 3) Run aws configure (enter s3-authorized IAM user and specify region, remember add permission for IAM can read/ write to S3)
 4) Fill in DB host + name
 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
 6) Run chmod +x backup.sh
 7) Test it out via ./backup.sh
 8) Set up a daily backup at midnight:
 
``0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log``

## Next version features
- Restore from S3