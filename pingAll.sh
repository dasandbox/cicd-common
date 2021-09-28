#!/bin/bash
# This script will ping one ip if passed as a cmd line arg from Jenkinsfile
# Or use readConfig.sh, but shell exports do not persist across stages

function pingit {
  local ip="${1}"

  if [ -z ${ip} ]; then
    echo "fail, ip empty!"
    return 1
  fi

  ip="$(echo "${ip}" | awk -F':' '{print $1}')"
  echo "ping: ${ip}"
  ping -c 4 -q "${ip}" 2>&1 >/dev/null

  if [ "$?" -eq 0 ]; then
    echo "ping OK - ${ip}"
    return 0
  else
    echo "ping FAIL - ${ip}"
    return 1
  fi
}

if [ $# -eq 1 ]; then
  pingit "${1}"
else
  source ./readConfig.sh
  pingit "${TTWCS}"    || exit 1
  pingit "${TMSERVER}" || exit 1
  pingit "${AMSERVER}" || exit 1
fi
