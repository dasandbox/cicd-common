#!/bin/bash

me=$(basename $0)
echo "me: ${me} $@"

if [[ $# -ne 1 ]]; then
  echo "Usage: ${me} <0|25|50|75|100>"
  exit
fi

pct=${1}

# Encode the URL, note the %25 at the end is the encoded "%" sign
URL="http://localhost:8080/job/DataCleanup/job/main/buildWithParameters?DeleteAnalysisData=${pct}%25"
echo "URL: ${URL}"

curl -X POST -vL --user auto:"$(< auto.TOKEN)"  "${URL}"
echo "retVal=$?"
