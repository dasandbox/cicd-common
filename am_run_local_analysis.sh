#!/bin/bash

me=$(basename $0)
#echo "me: ${me} $@"

# Use timestamp as default dataset/analysis id
idtag=$(date +%Y%m%d_%H%M%S)
if [ $# -eq 1 ]; then
  # Use user supplied name
  idtag="${1}"
fi

# Read config settings
source ./readConfig.sh
#echo "AMSERVER=${AMSERVER}"

url="http://${AMSERVER}/reaper/local_analysis?analysis_folder=Tomahawk&baseline=*&behaviors_script=Tomahawk-call-behaviors.py&events_script=Tomahawk-event-reconstruction.py&dataset=${idtag}&analysis_id=${idtag}"
echo "${url}"

# Make local_analysis request to run data analysis
resp="$( curl -sL -X POST ${url} )"
echo "resp=${resp}"

# No response at all, is Analysis Manager application running?
if [[ -z "${resp}" ]]; then
  echo "ERROR: No response at all from Analysis Manager on /reaper/local_analysis (is AM running??), exiting ..."
  exit 2
fi

echo "RunAnalysisJob started ..."
sleep 15

# Data loading should be happening now
while true; do

  # Make request to AM for job info
  resp="$( curl -sL http://${AMSERVER}/reaper/jobs_info )"
  #echo "resp=${resp}"
 
  resp="$(echo "${resp}" | jq '.RunAnalysisJob' | grep "Running analysis" )"
  echo "resp=${resp}"
  if [[ -z "${resp}" ]]; then
    echo "RunAnalysisJob complete!"
    break
  fi
  sleep 15
done
