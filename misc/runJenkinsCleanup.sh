#!/bin/bash

# This script will be used to run a Jenkins cleanup job nightly.
# Setup a cron job, something like nightly at 2AM:
# 0 2 * * * /bin/bash /home/jenkins/bin/runJenkinsCleanup.sh

LOG=/home/jenkins/job.log

echo $(date +%Y-%m-%d_%H:%M:%S) >> $LOG

# Need to cd into the script directory for access to auto.TOKEN
# that has the token needed to run the Jenkins job remotely
cd /home/jenkins/gitrepos/cicd-common
pwd >> $LOG

# Run the job, pass the "% to delete" as an argument to the script
/home/jenkins/gitrepos/cicd-common/run_jenkins_DataCleanup.sh 25 >> $LOG
echo >> $LOG

