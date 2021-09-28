#!/bin/bash

me=$(basename $0)
echo "me: ${me} $@"

if [[ $# -ne 2 ]]; then
  echo "Usage: ${me} <jobname> <branch>"
  exit
fi

job=${1}
branch=${2}

URL="http://localhost:8080/job/${job}/job/${branch}/build"
echo "URL: ${URL}"

curl -X POST -vL --user auto:"$(< auto.TOKEN)"  "${URL}"
echo "retVal=$?"
