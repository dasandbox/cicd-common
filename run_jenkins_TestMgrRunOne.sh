#!/bin/bash

me=$(basename $0)
echo "me: ${me} $@"

if [[ $# -ne 1 ]]; then
  echo "Usage: ${me} <testcase name>"
  exit
fi

# Replace spaces with URL encoded space
tcname=$( echo "${1}" | sed 's/ /%20/g' )

URL="http://localhost:8080/job/TestMgrRunOne/job/main/buildWithParameters?TestName=${tcname}"
echo "URL: ${URL}"

curl -X POST -vL --user auto:"$(< auto.TOKEN)"  "${URL}"
echo "retVal=$?"

