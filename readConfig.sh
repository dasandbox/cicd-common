#!/bin/bash

#me=$(basename $0)
#echo "me: ${me} $@"

file=config.json

server=$( jq -r .'ttwcs' "${file}" )
export TTWCS="${server}"
echo "TTWCS=${TTWCS}"

server=$( jq -r .'testMgr' "${file}" )
export TMSERVER="${server}"
echo "TMSERVER=${TMSERVER}"

server=$( jq -r .'analysisMgr' "${file}" )
export AMSERVER="${server}"
echo "AMSERVER=${AMSERVER}"

project=$( jq -r .'project' "${file}" )
export TMPROJECT="${project}"
echo "TMPROJECT=${TMPROJECT}"
