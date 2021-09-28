#!/bin/bash
# This script will start a Test Manager Testcase using the testcase_id

me=$(basename $0)
echo "me: ${me} $@"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <textcase-id>"
  exit 1
fi

tcid="${1}"

# Read TM config settings
source ./readConfig.sh

resp="$( curl -Ls -X POST -d '{"testcase_id": "'"${tcid}"'", "parameters":[]}' -H "Content-Type: application/json" http://"${TMSERVER}"/Testcase/Start )"
echo "start: ${resp}"

# No response at all, is Test Manager running?
if [[ -z "${resp}" ]]; then
  echo "ERROR: No response at all from Test Manager on /Testcase/Start (is TM running??), exiting ..."
  exit 2
fi

# Check the response value for "testcase_started"
resp="$( echo "${resp}" | jq '.testcase_started' )"
echo "testcase_started: ${resp}"
if [[ "${resp}" == "false" ]]; then
  echo "ERROR: Response from Test Manager on /Testcase/Start == false, exiting ..."
  exit 2
fi

echo "Testcase started ..."
sleep 15

# This part will monitor the progress of the TM testcase (if it starts).
# It will prevent the Jenkins job from finishing until the testcase is
# completed, or TM is not started/closes abrupty.
# There is some hokiness in the response messages where 'completed' may return
# true on its first reply, which is clearly incorrect and why the 'cnt' variable
# is used below. Also completed may return empty/null which is handled as well.
cnt=0
while true; do
  #resp="$( curl -Ls http://"${TMSERVER}"/Testcase/Progress?testflowID="${tcid}" )"
  resp="$( curl -Ls http://"${TMSERVER}"/Testcase/Running )"
  echo "resp: ${resp}"
  #resp="$( echo "${resp}" | jq -r '.completed' )"
  resp="$( echo "${resp}" | jq -r '.values[].testcase_name' )"
  echo "completed: ${resp}"

  if [[ -z "${resp}" ]]; then
    #echo "ERROR: No response from Test Manager on /Testcase/Progress, exiting ..."
    #exit 3
    echo "ERROR: No response from Test Manager on /Testcase/Running, testcase complete ..."
    break
  fi
  
  # Handling 'null' below is another way of handling "testcase_started:false" in the reply from /Testcase/Start
#  if [[ "${resp}" == "true" || "${resp}" == "null" ]]; then
#    ((cnt++))
#    if (( cnt > 1 )); then
#      echo "Testcase complete!"
#      break
#    fi
#  fi
  sleep 15
done
