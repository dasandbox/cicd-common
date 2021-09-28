#!/bin/bash
# This will find the project_id for any project name starting with "Tomhawk"

me=$(basename $0)
echo "me: ${me} $@"

# Read TM config settings
source readConfig.sh

curl -sL http://${TMSERVER}/Project | jq -r '.values[] | select(.project_name | startswith("Tomahawk")).project_id'
