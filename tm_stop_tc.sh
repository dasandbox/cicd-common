#!/bin/bash
# This script will stop a Test Manager Testcase using the testcase_id

me=$(basename $0)
echo "me: ${me} $@"

if [ $# -ne 1 ]; then
  echo "usage: $0 <textcase-id>"
  exit 1
fi

tc="${1}"

# Read TM config settings
source readConfig.sh

curl -Li -X POST http://"${TMSERVER}"/Testcase/Stop?testcase_id="${tc}"
