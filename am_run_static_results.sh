#!/bin/bash

# This script will make a request to AM for the list of analysis results.
# It will be used to delete results no longer of interest by the users.

me=$(basename $0)
echo "me: ${me} $@"

# An argument can be supplied for percaentage (0-100) of old files to remove
# If no argument is supplied, deletePercent=0
let delPct=${1:-0}

# Read config settings
source ./readConfig.sh


# ANALYSIS SECTION
# Make REST request to get list of analysis
resp="$( curl -sL http://${AMSERVER}/reaper/static_results )"

# No response at all, is Analysis Manager application running?
if [[ -z "${resp}" ]]; then
  echo "ERROR: No response at all from Analysis Manager on /reaper/static_results (is AM running??), exiting ..."
  exit 1
fi
echo "${resp}" > tempResultsFile

# Create an array of results for analysisIds
# The next command will read the response and find the analysisIds
# It will read all lines in the response containing "index.htm" (similar to below) and
# chop out the text between "static_results/" and "/index.htm"
#    <td><b><a href="static_results/DX20210914_194210/index.html">DX20210914_194210</a></b></td>
# Also note the use of tac below (instead of cat) to reverse the entries in the file, the results
# are normally displayed newest on top, they will be reversed to oldest on top before the delete calls
IFS_old="${IFS}"
IFS=$'\n'
results=( $( tac tempResultsFile | grep 'index.htm' | grep -o 'static_results/.*/index.htm' | sed 's/static_results\///' | sed 's/\/index.htm//' ) )
IFS="${IFS_old}"

echo "total=${#results[@]}"
if [[ "${#results[@]}" -gt 0 ]]; then

  for id in "${results[@]}"; do
    echo "${id}"
  done
  
  # Calculate number of entries to delete
  let delCnt=$(echo "${#results[@]} * ${delPct}/100" | bc)
  echo "delCnt=${delCnt}"
  
  # Make REST request to delete Analysis
  for (( i = 0; i < ${delCnt}; i++ )) ; do
    echo "${results[$i]}"
    resp=$( curl -sL -X DELETE http://"${AMSERVER}"/reaper/static_results/"${results[$i]}" )
    echo "resp: ${resp}"
  done
fi


# DATASET SECTION
# Make REST request to get list of datasets
results=( $( curl -sL http://"${AMSERVER}"/reaper/etl | jq -r '.tables_by_dataset[].dataset' ) )
echo "total=${#results[@]}"
if [[ "${#results[@]}" -gt 0 ]]; then
  
  for id in "${results[@]}"; do
    echo "${id}"
  done

  # Calculate number of entries to delete
  let delCnt=$(echo "${#results[@]} * ${delPct}/100" | bc)
  echo "delCnt=${delCnt}"

  # Make REST request to delete Dataset
  for (( i = 0; i < ${delCnt}; i++ )) ; do
    echo "${results[$i]}"
    resp=$( curl -sL -X DELETE http://"${AMSERVER}"/reaper/etl?dataset="${results[$i]}" )
    echo "resp: ${resp}"
  done
fi

# Delete all TM results for completed test executions (this call only works for all reports)
if [[ $delPct -eq 100 ]]; then
  echo "Deleting TM reports ..."
  resp=$( curl -sL -X DELETE http://"${TMSERVER}"/Testcase/Completed/AllResults )
  echo "resp: ${resp}"
fi
