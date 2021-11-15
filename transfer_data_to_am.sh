#!/bin/bash

# This script will move data files from TTWCS to AM using scp/rsync
# It will first clear the local cache and reaper_cache folders
# It will then transfer the files from TTWCS to here, then from here to AM reaper_cache

# Location of local cache
CACHE="/home/jenkins/WinShare"

# Location of REAPER cache
# Note the ATRT version in the path, so path may change with new zip file ...
AM_DATA="C:\\Users\\ttwcs\\Programs\\ATRT_AM\\RELEASE\\src\\analysis\\analysis.product\\target\\products\\com.idtus.atrt.analysis.all-rest\\win32\\win32\\x86_64\\reaper_cache\\etl\\local\\Tomahawk\\Baselines\\data"

# TTWCS DX data locations
# Data files may be in one of the following locations
# Sometimes they dont get moved to archive after a run, so first need
# to check "current", if no files are there, then grab from "archive"
TTWCS_CURR="/h/data/local/CSDX/data/dx_files/current/MM"
TTWCS_ARCH="/h/data/local/CSDX/data/dx_files/archive/MM"


# Read config settings
source ./readConfig.sh

# Clear local/reaper_cache
# Use IP address only from AM ip:port
ip="$( echo "${AMSERVER}" | awk -F':' '{print $1}' )"
resp="$( ssh ttwcs@${ip} "del /Q ${AM_DATA}" )"
rm -f "${CACHE}"/*.d1
echo "Cache cleared ..."
sleep 5 # So user can see file be removed and added


# Check if a .d1 file is in "current"
echo "Checking current files ..."
currentFile="$(ssh ttwcsop@${TTWCS} "ls -t ${TTWCS_CURR}/*.d1 | head -1")"
echo "currentFile: ${currentFile}"
if [[ ! -z ${currentFile} ]]; then
  # There is a file is in "current", grab it
  echo "Found a current file, Taking file from current directory ..."
else
  # In here means there is no file in "current", grab newest file from archive
  echo "No current file found, Taking the newest archive file ..."
  currentFile="$(ssh ttwcsop@${TTWCS} "ls -t ${TTWCS_ARCH}/*.d1 | head -1")"
  echo "archiveFile: ${currentFile}"
fi

# Verify there is a d1 file in either location
if [[ -z ${currentFile} ]]; then
  echo "No current/archive data files exist, something went wrong, exiting ..."
  exit 1
fi

# Write the filename to a temp file, AM will use this as the Dataset/AnalysisId in the next script
# Convert DX20210901_231337.d1 -> DX20210901_231337
echo $(basename "${currentFile}" .d1) > currentDxFile

# Copy the data file from TTWCS to local cache
resp="$( rsync -ahvz --ignore-existing ttwcsop@${TTWCS}:${currentFile} ${CACHE} )"
echo "resp: ${resp}"

echo "cache:"
ls ${CACHE}/*.d1

# Verify that we have the file locally, check the cache for a single file
count=$( ls -F "${CACHE}" | grep -v / | wc -l )
echo "cache count: $count"
if [ ${count} -ne 1 ]; then
  echo "Cache has ${count} files, something went wrong, exiting ..."
  exit 2
else
  # Copy the data file from local cache to AM reaper_cache
  # Use IP address only from AM ip:port
  ip="$( echo "${AMSERVER}" | awk -F':' '{print $1}' )"
  resp="$( scp ${CACHE}/*.d1 ttwcs@${ip}:${AM_DATA} )"
  echo "resp: ${resp}"
fi

