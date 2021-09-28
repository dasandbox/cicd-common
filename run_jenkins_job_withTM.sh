#!/bin/bash

me=$(basename $0)
echo "me: ${me} $@"

if [[ $# -ne 3 ]]; then
  echo "Usage: ${me} <jobname> <branch> <run-TM=true|false>"
  exit
fi

job=${1}
branch=${2}
tm=${3}

URL="http://localhost:8080/job/${job}/job/${branch}/buildWithParameters?RunTestManager=${tm}"
echo "URL: ${URL}"

curl -X POST -vL --user auto:"$(< auto.TOKEN)"  "${URL}"
echo "retVal=$?"
