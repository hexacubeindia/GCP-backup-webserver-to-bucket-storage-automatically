# GCP-backup-webserver-to-bucket-storage-automatically

Bash scripts for executing and maintaining daily, weekly and monthly backups of files and databases in GCP webserver.


All files (folders of all websites) will be compressed into a single archive.
All databases will be dumped seperately in archive formats.

Archives will be transferred to GCP cloud buckets.

Daily backup will erase old backup and replace with new one daily.

Weekly backup will keep 7 recent backups

Monthly backup will keep backups taken in 1st of every month for 12 months.
