#!/bin/bash

# This script will be used to run a Jenkins testcase job nightly.
# Setup a cron job, something like nightly at 2AM:
# 0 2 * * * /bin/bash /home/jenkins/bin/runJenkinsTestcase.sh

LOG=/home/jenkins/job.log

me=$(basename $0)
echo "me: ${me} $@" >> $LOG

echo $(date +%Y-%m-%d_%H:%M:%S) >> $LOG

# Need to cd into the script directory for access to auto.TOKEN
# that has the token needed to run the Jenkins job remotely
cd /home/jenkins/gitrepos/cicd-common
pwd >> $LOG

# Basic GoPath_TC
# Specific Tasks_MMCP_TC
# Allocation Required_MMCP_TC

# Run the job, pass the "testcase name" as an argument to the script
/home/jenkins/gitrepos/cicd-common/run_jenkins_TestMgrRunOne.sh "Basic GoPath_TC" >> $LOG
echo >> $LOG

