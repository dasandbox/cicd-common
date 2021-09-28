#!/bin/bash

me=$(basename $0)
echo "me: ${me} $@"

if [ $# -eq 1 ]; then
  TMSERVER="${1}"
else
  # Read TM config settings, but shell exports wont persist in Jenkinsfile
  source ./readConfig.sh
fi

# These files will hold project/tectcase ids
tpidfile=tomahawk-tpid.txt
tcidfile=tomahawk-tcid.txt

# Make request for the project_id for Tomahawk
tpid="$( curl -sL http://${TMSERVER}/Project | jq -r '.values[] | select(.project_name | startswith("Tomahawk")) | "'"\\(.project_id)"'"' )"
echo "tpid=${tpid}"
if [[ -z "${tpid}" ]]; then
  echo "ERROR: No response at all from Test Manager on /Project (is TM running??), exiting ..."
  exit 1
fi

# Write the project_id to file
echo "${tpid}" > "${tpidfile}"

# Make request for testcase_ids for the project_id
tcids="$( curl -sL http://${TMSERVER}/Project/Testcases?project_id="$tpid" | jq -r '.values[] | "'"\\(.testcase_id):\\(.testcase_name)"'"' )"
if [[ ! -z ${tcids} ]]; then
  # Write all testcases (testcase_id:testcase_name) to file
  echo "${tcids}" > "${tcidfile}"
fi
