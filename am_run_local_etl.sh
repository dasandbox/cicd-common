#!/bin/bash

me=$(basename $0)
#echo "me: ${me} $@"

# The CI/CD pipeline will name the data/analysis same as the current DX file
# This script can use a timestamp as the dataset/analysis if nothing supplied
idtag=$(date +%Y%m%d_%H%M%S)
if [ $# -eq 1 ]; then
  # Use user supplied name
  idtag="${1}"
fi

# The CI/CD pipeline will support TTWCS baselines 5.6.0 and 5.6.1
baseline=TTWCS_Baseline_5_6_1
if [ $# -eq 2 ]; then
  # Use user supplied baseline
  baseline="${2}"
fi

# Read config settings
source ./readConfig.sh
echo "AMSERVER=${AMSERVER}"

url="http://${AMSERVER}/reaper/local_etl?etl_folder=./Tomahawk/Baselines&analysis_id=${idtag}&catalog_file_dir=${baseline}/catalogs&data_file_dir=data"
echo "url=${url}"

# Make local_etl request to read data files
resp="$( curl -sL -X POST ${url} )"
echo "resp=${resp}"

# No response at all, is Analysis Manager application running?
if [[ -z "${resp}" ]]; then
  echo "ERROR: No response at all from Analysis Manager on /reaper/local_etl (is AM running??), exiting ..."
  exit 2
fi

echo "LoadDataFilesJob started ..."

# Data loading should be happening now
while true; do

  # Make request to AM for job info
  resp="$( curl -sL http://${AMSERVER}/reaper/jobs_info )"
  #echo "resp=${resp}"

  resp="$(echo "${resp}" | jq '.LoadDataFilesJob' | grep "Loading" )"
  echo "resp=${resp}"
  if [[ -z "${resp}" ]]; then
    echo "LoadDataFilesJob complete!"
    break
  fi
  sleep 15
done
