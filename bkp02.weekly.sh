#!/bin/bash
# Author: L. Anantha Raman
# Script Name: Backup to Bucket
# Script Description: Create archives of all websites and databases, make a copy to bucket and delete local copy.
# Company: hexacube India
# Website: www.hexacube.in
# Phone: +91 9003314466
# Email: info@hexacube.in
# Last Updated: 2018-01-11
#
####################### VARIABLES #######################
#########################################################
#
todayfile=$(date -d @$(( $(date +"%s") + 19800)) +"%Y-%m-%d-%H-%M")
#
##################### VARIABLES ENDS ####################
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
echo " "
echo "Backup to Bucket (weekly) process started at $todayfile"
sleep 1
#
#---------------------------------------------------------------------------------------------------------------------------#
#
################ CHOOSE BACKUP DIRECTORY ################
#########################################################
#
fpath=/srv/users/serverpilot/backup/backuptobucket
bkppath=/srv/users/serverpilot/apps/
#
############ BACKUP DIRECTORY SETTINGS ENDS #############
######################################################### 
#
#---------------------------------------------------------------------------------------------------------------------------#
#
############# PRE TRANSFER DELETION STARTS ##############
#########################################################
#
echo " "
echo "Cleaning local backup directory"
rm -r $fpath/*
#
############## PRE TRANSFER DELETION ENDS ###############
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
############## LOOP FOR FILE BACKUP STARTS ##############
#########################################################
#
mkdir -p $fpath/$todayfile
echo " "
echo "File archiving started"
tar -czf $fpath/$todayfile/filebkp.tar.gz -C $bkppath .
echo " "
echo "File archiving completed"
sleep 2
#
############### LOOP FOR FILE BACKUP ENDS ###############
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
############ LOOP FOR DATABASE BACKUP STARTS ############
#########################################################
#
### MySQL Setup Starts###
MUSER="<replace with db root username>"
MPASS="<replace with db root password>"
### MySQL Setup Ends###
#
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"
#
echo " "
echo "Database archiving started"
echo " "
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
if [ "$db" == "mysql" ]
then
echo "System database mysql has been skipped"
echo " "
elif [ "$db" == "information_schema" ]
then
echo "System database information_schema has been skipped"
echo " "
elif [ "$db" == "performance_schema" ]
then
echo "System database performance_schema has been skipped"
echo " "
elif [ "$db" == "phpmyadmin" ]
then
echo "System database phpmyadmin has been skipped"
echo " "
elif [ "$db" == "sys" ]
then
echo "System database sys has been skipped"
echo " "
else
 FILE=$fpath/$todayfile/dbbkp-$db.sql
 mysqldump -u$MUSER -p$MPASS $db > $FILE
 echo "Archive created for database $db"
 echo " "
 sleep 2
fi
done
echo "Database archiving completed"
sleep 2
#
############# LOOP FOR DATABASE BACKUP ENDS #############
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
################ BUCKET TRANSFER STARTS #################
#########################################################
#
echo " "
echo "Copying Backup Archives of $todayfolder to cloud bucket"
echo " "
gsutil -m cp -r $fpath/$todayfile gs://bkp02.weekly.hexacubellc.cf
sleep 1
echo " "
echo "Transfer to Bucket Completed"
#
################# BUCKET TRANSFER ENDS ##################
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
############# POST TRANSFER DELETION STARTS #############
#########################################################
#
echo " "
echo "Cleaning local backup directory"
echo " "
rm -r $fpath/*
endtime=$(date -d @$(( $(date +"%s") + 19800)) +"%Y-%m-%d-%H-%M")
echo "Backup to Bucket process ended at  $endtime"
echo " "
#
############## POST TRANSFER DELETION ENDS ##############
#########################################################
#
#---------------------------------------------------------------------------------------------------------------------------#
#
#################### SUMMARY STARTS #####################
#########################################################
#
echo "**************************************************"
echo " "
echo "Cloud Bucket Backup Individual Files Sizes:"
echo " "
gsutil du -ch gs://bkp02.weekly.hexacubellc.cf/
echo " "
echo " "
echo "Cloud Bucket Backup Overall Disk Usage:"
echo " "
gsutil du -s -h gs://bkp02.weekly.hexacubellc.cf
echo " "
echo "**************************************************"
#
##################### SUMMARY ENDS ######################
#########################################################
