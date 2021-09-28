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
echo "AMSERVER=${AMSERVER}"

url="http://${AMSERVER}/reaper/local_etl?etl_folder=./Tomahawk&analysis_id=${idtag}&catalog_file_dir=catalog&data_file_dir=data"
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
